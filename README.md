# Dev.to Article Publisher

Скрипт для публикации статей на Dev.to через API с поддержкой вебхуков и автоматической конвертацией HTML в Markdown.

## Требования

- Ruby
- API ключ от Dev.to
- Bundler для управления зависимостями

## Возможности

- Публикация статей через API Dev.to
- Поддержка вебхуков для автоматической публикации
- Автоматическая конвертация HTML в Markdown
- Поддержка мета-описаний и обложек статей
- Безопасная валидация вебхуков через секретный ключ

## Настройка

1. Получите API ключ на странице [Dev.to Settings](https://dev.to/settings/account)
2. Установите необходимые переменные окружения:

```bash
# API ключ для Dev.to
export DEVTO_API_KEY='ваш-api-ключ'
# Секретный ключ для вебхуков (придумайте свой)
export WEBHOOK_SECRET='ваш-секретный-ключ'
```

3. Установите зависимости:

```bash
bundle install
```

## Использование

### Как скрипт командной строки

1. Подготовьте JSON файл с данными статьи (см. `article.json` для примера)
2. Запустите скрипт:

```bash
ruby post_to_devto.rb article.json
```

### Как вебхук-сервер

1. Запустите сервер:

```bash
bundle exec rackup config.ru -p 3000
```

2. Настройте вебхук в вашей системе, указав:
   - URL: `http://ваш-домен:3000`
   - Заголовок `X-SECRET` со значением из `WEBHOOK_SECRET`

Сервер будет принимать POST-запросы с JSON-данными статьи и публиковать их на Dev.to.

## Формат JSON

```json
{
  "title": "Заголовок статьи",
  "content": "HTML контент",
  "content_markdown": "Markdown контент",
  "tags": ["тег1", "тег2"],
  "thumbnail": "URL изображения",
  "thumbnail_alt_text": "Описание изображения",
  "metadescription": "META описание",
  "keyword_seed": "Ключевое слово",
  "language_code": "Код языка"
}
```

### Особенности контента

- Можно использовать либо `content` (HTML), либо `content_markdown` (Markdown)
- Если указаны оба поля, будет использован `content_markdown`
- HTML контент автоматически конвертируется в Markdown с помощью библиотеки `reverse_markdown`
- При ошибке конвертации используется упрощённый алгоритм преобразования

### Дополнительные поля

- `thumbnail` - URL обложки статьи
- `metadescription` - META-описание для SEO
- `tags` - массив тегов для категоризации
- `language_code` - код языка статьи

### Run webhook server

1. Start the server:

```bash
bundle exec puma -C config/puma.rb
```

The server will run on port 3000 by default. You can change it by setting the PORT environment variable:

```bash
PORT=4000 bundle exec puma -C config/puma.rb
```


## Local testing WebHook

Add how to test locally webhook need to install

> npm install -g localtunnel

> bundle exec puma -C config/puma.rb

> lt --port 3000 -l

> bundle exec ruby test/send_webhook.rb <url from the previous command>
