require_relative 'test_helper'

class DevtoPublisherTest < Minitest::Test
  def setup
    @api_key = 'test_api_key'
    @client = DevtoPublisher::Client.new(@api_key)
  end

  def test_requires_api_key
    assert_raises(DevtoPublisher::ConfigError) { DevtoPublisher::Client.new(nil) }
    assert_raises(DevtoPublisher::ConfigError) { DevtoPublisher::Client.new('') }
  end

  def test_creates_article_with_markdown_content
    article_data = {
      'title' => 'Test Article',
      'content_markdown' => '## Test Content',
      'tags' => ['test']
    }

    stub_devto_api_request(article_data)
    response = @client.create_article(article_data)

    assert_equal 'https://dev.to/articles/123', response['url']
  end

  def test_creates_article_with_html_content
    article_data = {
      'title' => 'Test Article',
      'content' => '<h2>Test Content</h2>',
      'tags' => ['test']
    }

    stub_devto_api_request(article_data)
    response = @client.create_article(article_data)

    assert_equal 'https://dev.to/articles/123', response['url']
  end

  def test_handles_api_error
    article_data = { 'title' => 'Test', 'content_markdown' => 'Test' }

    stub_request(:post, DevtoPublisher::Client::DEVTO_API_URL)
      .to_return(status: 422, body: '{"error": "Invalid request"}')

    assert_raises(DevtoPublisher::APIError) do
      @client.create_article(article_data)
    end
  end

  def test_requires_content
    article_data = { 'title' => 'Test' }

    assert_raises(DevtoPublisher::Error) do
      @client.create_article(article_data)
    end
  end

  def test_includes_optional_fields
    article_data = {
      'title' => 'Test Article',
      'content_markdown' => '## Test',
      'metadescription' => 'Test description',
      'thumbnail' => 'https://example.com/image.jpg',
      'tags' => ['test']
    }

    stub_devto_api_request(article_data)
    @client.create_article(article_data)

    assert_requested(:post, DevtoPublisher::Client::DEVTO_API_URL) do |req|
      body = JSON.parse(req.body)
      assert_equal 'Test description', body['article']['description']
      assert_equal 'https://example.com/image.jpg', body['article']['main_image']
    end
  end

  def test_handles_duplicate_title_error
    article_data = { 'title' => 'Test', 'content_markdown' => 'Test' }

    stub_request(:post, DevtoPublisher::Client::DEVTO_API_URL)
      .to_return(
        status: 422,
        body: { error: "Title has already been used in the last five minutes" }.to_json
      )

    error = assert_raises(DevtoPublisher::APIError) do
      @client.create_article(article_data)
    end

    error_response = JSON.parse(error.message)
    assert_equal "Title has already been used in the last five minutes", error_response['error']
    assert_equal 422, error_response['status']
  end

  private

  def stub_devto_api_request(article_data)
    stub_request(:post, DevtoPublisher::Client::DEVTO_API_URL)
      .with(
        headers: {
          'content-type' => 'application/json',
          'api-key' => @api_key
        }
      )
      .to_return(
        status: 200,
        body: { id: 123 }.to_json,
        headers: { 'content-type' => 'application/json' }
      )
  end

  def test_devto_payload_matches_input_data
    article_data = {
      'title' => 'Test Article',
      'content_markdown' => '## Test Content',
      'tags' => ['ruby', 'api'],
      'metadescription' => 'Test description',
      'thumbnail' => 'https://example.com/image.jpg'
    }

    stub_devto_api_request(article_data)
    @client.create_article(article_data)

    assert_requested(:post, DevtoPublisher::Client::DEVTO_API_URL) do |req|
      body = JSON.parse(req.body)
      article = body['article']

      assert_equal article_data['title'], article['title']
      assert_equal article_data['content_markdown'], article['body_markdown']
      assert_equal article_data['tags'], article['tags']
      assert_equal article_data['metadescription'], article['description']
      assert_equal article_data['thumbnail'], article['main_image']
      assert_equal DevtoPublisher::Client::ORGANIZATION_ID, article['organization_id']
      refute article['published']
    end
  end

  def test_converts_html_to_markdown_when_no_markdown_provided
    article_data = {
      'title' => 'Test Article',
      'content' => '<h2>Test Content</h2><p>Some text</p>',
      'tags' => ['ruby']
    }

    stub_devto_api_request(article_data)
    @client.create_article(article_data)

    assert_requested(:post, DevtoPublisher::Client::DEVTO_API_URL) do |req|
      body = JSON.parse(req.body)
      article = body['article']

      assert_equal "## Test Content\n\nSome text", article['body_markdown']
    end
  end
end
