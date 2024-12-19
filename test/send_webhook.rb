#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'
require 'dotenv'

# Загружаем переменные окружения из .env
Dotenv.load

require 'bundler/setup'
Bundler.require


# Конфигурация
WEBHOOK_URL = ARGV[0] || 'https://heavy-pillows-rush.loca.lt'
WEBHOOK_SECRET = ENV['WEBHOOK_SECRET']

# Тестовый payload для статьи
article_payload = JSON.parse(File.read('test/fixtures/article.json'))

# Создаем URI объект
uri = URI(WEBHOOK_URL)

# Создаем HTTP объект
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = uri.scheme == 'https'
http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Для локального тестирования

# Создаем запрос
request = Net::HTTP::Post.new(uri.path.empty? ? '/' : uri.path)
request['content-type'] = 'application/json'
request['x-secret'] = WEBHOOK_SECRET
request.body = article_payload.to_json

# Отправляем запрос
begin
  response = http.request(request)
  puts "Статус: #{response.code}"
  puts "Ответ: #{response.body}"
rescue => e
  puts "Ошибка: #{e.message}"
end
