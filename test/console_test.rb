require 'test_helper'
require 'shopify_api_console/console'
require 'fileutils'
class ConsoleTest < Minitest::Test
  HOME_DIR = File.expand_path(File.dirname(__FILE__))
  TEST_HOME = File.join(HOME_DIR, 'files', 'home')
  CONFIG_DIR = File.join(TEST_HOME, '.shopify', 'shops')
  DEFAULT_SYMLINK = File.join(CONFIG_DIR, 'default')

  def setup
    force_remove(TEST_HOME)

    ENV['HOME'] = TEST_HOME
    @console = ShopifyAPIConsole::Console.new

    FileUtils.mkdir_p(CONFIG_DIR)
    Dir.chdir(CONFIG_DIR)

    add_config('foo', default: true, config: valid_options.merge(domain: 'foo.myshopify.com'))
    add_config('bar', config: valid_options.merge(domain: 'bar.myshopify.com'))
  end

  def teardown
    Dir.chdir(HOME_DIR)
    force_remove(TEST_HOME)
  end

  test "add with blank domain" do
    standard_add_shop_prompts
    $stdin.expects(:gets).times(5).returns("", "key", "pass", "v1", "y")
    @console.expects(:puts).with("\nopen https://foo.myshopify.com/admin/apps/private in your browser to create a private app and get API credentials\n")
    @console.expects(:puts).with("Default connection is foo")

    @console.add('foo')

    config = YAML.load(File.read(config_file('foo')))
    assert_equal 'foo.myshopify.com', config['domain']
    assert_equal 'key', config['api_key']
    assert_equal 'pass', config['password']
    assert_equal 'v1', config['api_version']
    assert_equal 'pry', config['shell']
    assert_equal 'https', config['protocol']
    assert_equal config_file('foo'), File.readlink(DEFAULT_SYMLINK)
  end

  test "add with explicit domain" do
    standard_add_shop_prompts
    $stdin.expects(:gets).times(5).returns("bar.myshopify.com", "key", "pass", "v1", "y")
    @console.expects(:puts).with("\nopen https://bar.myshopify.com/admin/apps/private in your browser to create a private app and get API credentials\n")
    @console.expects(:puts).with("Default connection is foo")

    @console.add('foo')

    config = YAML.load(File.read(config_file('foo')))
    assert_equal 'bar.myshopify.com', config['domain']
  end

  test "add with blank api version should set latest api version last quarter release" do
    api_released_month_by_current_month = {
      1 => "01", 2 => "01", 3 => "01",
      4 => "04", 5 => "04", 6 => "04",
      7 => "07", 8 => "07", 9 => "07",
      10 => "10", 11 => "10", 12 => "10",
    }

    api_released_month_by_current_month.each do |current_month, released_month|
      Time.stub :now, Time.new(2021, current_month) do
        standard_add_shop_prompts
        $stdin.expects(:gets).times(5).returns("bar.myshopify.com", "key", "pass", "", "fuuuuuuu")
        @console.expects(:puts).with("\nopen https://bar.myshopify.com/admin/apps/private in your browser to create a private app and get API credentials\n")
        @console.expects(:puts).with("Default connection is foo")
  
        @console.add('foo')
        config = YAML.load(File.read(config_file('foo')))
  
        assert_equal "2021-#{released_month}", config['api_version']
      end
    end
  end

  test "add with irb as shell" do
    standard_add_shop_prompts
    $stdin.expects(:gets).times(5).returns("bar.myshopify.com", "key", "pass", "v1", "fuuuuuuu")
    @console.expects(:puts).with("\nopen https://bar.myshopify.com/admin/apps/private in your browser to create a private app and get API credentials\n")
    @console.expects(:puts).with("Default connection is foo")

    @console.add('foo')

    config = YAML.load(File.read(config_file('foo')))
    assert_equal 'irb', config['shell']
  end

  test "list" do
    @console.expects(:puts).with("   bar")
    @console.expects(:puts).with(" * foo")

    @console.list
  end

  test "show default" do
    @console.expects(:puts).with("Default connection is foo")

    @console.default
  end

  test "set default" do
    @console.expects(:puts).with("Default connection is bar")

    @console.default('bar')

    assert_equal config_file('bar'), File.readlink(DEFAULT_SYMLINK)
  end

  test "remove default connection" do
    @console.remove('foo')

    assert !File.exist?(DEFAULT_SYMLINK)
    assert !File.exist?(config_file('foo'))
    assert File.exist?(config_file('bar'))
  end

  test "remove non-default connection" do
    @console.remove('bar')

    assert_equal 'foo.yml', File.readlink(DEFAULT_SYMLINK)
    assert File.exist?(config_file('foo'))
    assert !File.exist?(config_file('bar'))
  end

  private

  def valid_options
    {'domain' => 'snowdevil.myshopify.com', 'api_key' => 'key', 'password' => 'pass', 'api_version' => 'v1', 'shell' => 'pry', 'protocol' => 'https'}
  end

  def config_file(connection)
    File.join(CONFIG_DIR, "#{connection}.yml")
  end

  def add_config(name, config: nil, default: false)
    File.open("#{name}.yml", 'w') do |file|
      file.puts config.to_yaml
    end
    File.symlink("#{name}.yml", DEFAULT_SYMLINK) if default
  end

  def standard_add_shop_prompts
    force_remove("#{CONFIG_DIR}/*")

    $stdout.expects(:print).with("Domain? (leave blank for foo.myshopify.com) ")
    $stdout.expects(:print).with("API key? ")
    $stdout.expects(:print).with("Password? ")
    $stdout.expects(:print).with("API version? Leave blank for the latest version ")
    $stdout.expects(:print).with("Would you like to use pry as your shell? (y/n) ")
  end

  def force_remove(pattern)
    `rm -rf #{pattern}`
  end

end
