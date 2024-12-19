# Dev.to Article Publisher

Script for publishing articles on Dev.to via API with webhook support and automatic HTML to Markdown conversion.

## Requirements

- Ruby
- API key from Dev.to
- Bundler for dependency management

## Features

- Publishing articles via Dev.to API
- Webhook support for automatic publishing
- Automatic HTML to Markdown conversion
- Support for meta descriptions and article covers
- Secure webhook validation via secret key

## Setup

1. Get the API key from the [Dev.to Settings](https://dev.to/settings/account) page
2. Set the required environment variables:

```bash
# API key for Dev.to
export DEVTO_API_KEY='your-api-key'
# Secret key for webhooks (create your own)
export WEBHOOK_SECRET='your-secret-key'
```

or update .env file with your keys:

```bash
cp .env.example .env
```

