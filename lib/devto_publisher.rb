require 'json'
require 'net/http'
require 'uri'
require 'reverse_markdown'

module DevtoPublisher
  class Error < StandardError; end
  class ConfigError < Error; end
  class APIError < Error; end

  class Client
    DEVTO_API_URL = 'https://dev.to/api/articles'.freeze
    ORGANIZATION_ID = 2669

    def initialize(api_key = ENV['DEVTO_API_KEY'])
      raise ConfigError, 'API key is required' if api_key.nil? || api_key.empty?
      @api_key = api_key
    end

    def create_article(article_data)
      response = make_request(prepare_article_data(article_data))
      puts response.body
      handle_response(response)
    end

    private

    def prepare_article_data(article_data)
      {
        article: {
          title: article_data.fetch('title'),
          body_markdown: get_markdown_content(article_data),
          published: false,
          tags: article_data['tags']&.map {|tag| tag.gsub(/[^\p{Alnum}]/, '')},
          organization_id: ORGANIZATION_ID,
          description: article_data['metadescription'],
          main_image: article_data['thumbnail']
        }.compact
      }
    end

    def get_markdown_content(article_data)
      return article_data['content_markdown'] if article_data['content_markdown']
      return convert_html_to_markdown(article_data['content']) if article_data['content']
      raise Error, 'Either content_markdown or content is required'
    end

    def convert_html_to_markdown(html)
      ReverseMarkdown.convert(html)
    end

    def fallback_html_to_markdown(html_content)
      HtmlUtils.fallback_html_to_markdown(html_content)
    end

    def make_request(data)
      uri = URI.parse(DEVTO_API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path)
      request['content-type'] = 'application/json'
      request['api-key'] = @api_key

      request.body = data.to_json

      http.request(request)
    end

    def handle_response(response)
      case response
      when Net::HTTPSuccess
        result = JSON.parse(response.body)
        { 'url' => "https://dev.to#{result['path']}" }
      else
        raise APIError, response.body
      end
    end
  end
end
