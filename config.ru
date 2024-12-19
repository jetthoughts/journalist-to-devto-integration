require 'json'
require 'rack'
require 'dotenv'
require_relative 'lib/devto_publisher'

# Загружаем переменные окружения из .env файла
Dotenv.load

class WebhookServer
  def initialize
    @secret = ENV['WEBHOOK_SECRET']
    @publisher = DevtoPublisher::Client.new

    unless @secret
      puts "Error: Please set WEBHOOK_SECRET environment variable"
      exit 1
    end
  end

  def call(env)
    request = Rack::Request.new(env)

    # Check request method
    return error_response(405, "Method not allowed") unless request.post?

    # Validate secret key
    secret_header = request.env['HTTP_X_SECRET']
    return error_response(401, "Invalid secret key") unless valid_secret?(secret_header)

    # Read and validate request body
    begin
      body = request.body.read
      payload = JSON.parse(body)
    rescue JSON::ParserError
      return error_response(400, "Invalid JSON format")
    end

    # Post article to dev.to
    begin
      result = @publisher.create_article(payload)
      [200, { 'content-type' => 'application/json' }, [result.to_json]]
    rescue DevtoPublisher::Error => e
      error_response(500, e.message)
    end
  end

  private

  def valid_secret?(header_secret)
    return false unless header_secret
    Rack::Utils.secure_compare(@secret, header_secret)
  end

  def error_response(status, message)
    [status, { 'content-type' => 'application/json' }, [{ error: message, status: 500 }.to_json]]
  end
end

run WebhookServer.new
