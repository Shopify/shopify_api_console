require 'rubygems'
require 'minitest/autorun'
require 'fakeweb'
require 'webmock/minitest'
require 'mocha/setup'
require 'json'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'shopify_api_console'
require 'shopify_api'

FakeWeb.allow_net_connect = false

# setup ShopifyAPI with fake api_key and secret

class Minitest::Test
  def self.test(string, &block)
    define_method("test_#{string}", &block)
  end

  def self.should(string, &block)
    self.test("should_#{string}", &block)
  end

  def self.context(string)
    yield
  end

  def setup
    ActiveResource::Base.format = :json
    ShopifyAPI.constants.each do |const|
      begin
        const = "ShopifyAPI::#{const}".constantize
        const.format = :json if const.respond_to?(:format=)
      rescue NameError
      end
    end

    ShopifyAPI::Base.clear_session
    ShopifyAPI::Base.site = "https://this-is-my-test-shop.myshopify.com/admin"
    ShopifyAPI::Base.password = nil
    ShopifyAPI::Base.user = nil
  end

  def teardown
    FakeWeb.clean_registry
  end

  # Custom Assertions
  def assert_not(expression)
    assert_block("Expected <#{expression}> to be false!") { not expression }
  end

  def load_fixture(name, format=:json)
    File.read(File.dirname(__FILE__) + "/fixtures/#{name}.#{format}")
  end

  def fake(endpoint, options={})
    body   = options.has_key?(:body) ? options.delete(:body) : load_fixture(endpoint)
    format = options.delete(:format) || :json
    method = options.delete(:method) || :get
    extension = ".#{options.delete(:extension)||'json'}" unless options[:extension]==false

    url = if options.has_key?(:url)
      options[:url]
    else
      "https://this-is-my-test-shop.myshopify.com/admin/#{endpoint}#{extension}"
    end

    FakeWeb.register_uri(method, url, {:body => body, :status => 200, :content_type => "text/#{format}", :content_length => 1}.merge(options))
  end
end
