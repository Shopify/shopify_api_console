require 'thor'
require 'abbrev'
require 'yaml'
require 'shopify_api'
require 'net/http'
require 'uri'
require 'json'

module ShopifyAPIConsole
  class Console < Thor
    include Thor::Actions

    class ConfigFileError < StandardError
    end

    desc "list", "list available connections"
    def list
      available_connections.each do |c|
        prefix = default?(c) ? " * " : "   "
        puts prefix + c
      end
    end

    desc "add CONNECTION", "create a config file for a connection named CONNECTION"
    def add(connection)
      file = config_file(connection)
      if File.exist?(file)
        raise ConfigFileError, "There is already a config file at #{file}"
      else
        config = {'protocol' => 'https'}
        config['domain']   = ask("Domain? (leave blank for #{connection}.myshopify.com)")
        config['domain']   = "#{connection}.myshopify.com" if config['domain'].blank?
        config['domain']   = "#{config['domain']}.myshopify.com" unless config['domain'].match(/[.:]/)
        puts "\nopen https://#{config['domain']}/admin/apps/private in your browser to create a private app and get API credentials\n"
        config['api_key']  = ask("API key?")
        config['password'] = ask("Password?")
        config['api_version'] = ask("API version? Leave blank for the latest version")
        config['api_version'] = shopify_api_latest_version(config) if config['api_version'].blank?
        if ask("Would you like to use pry as your shell? (y/n)") === "y"
          config["shell"] = "pry"
        else
          config["shell"] = "irb"
        end
        create_file(file, config.to_yaml)
      end
      if available_connections.one?
        default(connection)
      end
    end

    desc "remove CONNECTION", "remove the config file for CONNECTION"
    def remove(connection)
      file = config_file(connection)
      if File.exist?(file)
        remove_file(default_symlink) if default?(connection)
        remove_file(file)
      else
        no_config_file_error(file)
      end
    end

    desc "edit [CONNECTION]", "open the config file for CONNECTION with your default editor"
    def edit(connection=nil)
      file = config_file(connection)
      if File.exist?(file)
        if ENV['EDITOR'].present?
          system(ENV['EDITOR'], file)
        else
          puts "Please set an editor in the EDITOR environment variable"
        end
      else
        no_config_file_error(file)
      end
    end

    desc "show [CONNECTION]", "output the location and contents of the CONNECTION's config file"
    def show(connection=nil)
      connection ||= default_connection
      file = config_file(connection)
      if File.exist?(file)
        puts file
        puts `cat #{file}`
      else
        no_config_file_error(file)
      end
    end

    desc "default [CONNECTION]", "show the default connection, or make CONNECTION the default"
    def default(connection=nil)
      if connection
        target = config_file(connection)
        if File.exist?(target)
          remove_file(default_symlink)
          `ln -s #{target} #{default_symlink}`
        else
          no_config_file_error(target)
        end
      end
      if File.exist?(default_symlink)
        puts "Default connection is #{default_connection}"
      else
        puts "There is no default connection set"
      end
    end

    desc "console [CONNECTION]", "start an API console for CONNECTION"
    def console(connection=nil)
      file = config_file(connection)

      config = YAML.load(File.read(file))
      puts "using #{config['domain']}"
      ShopifyAPI::Base.site = site_from_config(config)

      logger = Logger.new(STDOUT)
      logger.level = Logger::WARN
      ActiveResource::Base.logger = logger

      launch_shell(config)
    end

    tasks.keys.abbrev.each do |shortcut, command|
      map shortcut => command.to_sym
    end

    private

    def shop_config_dir
      @shop_config_dir ||= File.join(ENV['HOME'], '.shopify', 'shops')
    end

    def default_symlink
      @default_symlink ||= File.join(shop_config_dir, 'default')
    end

    def config_file(connection)
      if connection
        File.join(shop_config_dir, "#{connection}.yml")
      else
        default_symlink
      end
    end

    def site_from_config(config)
      protocol = config['protocol'] || 'https'
      api_key  = config['api_key']
      password = config['password']
      domain   = config['domain']
      api_version = config['api_version']

      ShopifyAPI::Base.site = "#{protocol}://#{api_key}:#{password}@#{domain}/admin"
      ShopifyAPI::Base.api_version = api_version
    end

    def launch_shell(config)
      if config["shell"] === "pry"
        require 'pry'
        ARGV.clear
        Pry.start
      else
        require 'irb'
        require 'irb/completion'
        ARGV.clear
        IRB.start
      end
    end

    def available_connections
      @available_connections ||= begin
        pattern = File.join(shop_config_dir, "*.yml")
        Dir.glob(pattern).map { |f| File.basename(f, ".yml") }
      end
    end

    def default_connection_target
      @default_connection_target ||= File.readlink(default_symlink)
    end

    def default_connection
      @default_connection ||= File.basename(default_connection_target, ".yml")
    end

    def default?(connection)
      default_connection == connection
    end

    def no_config_file_error(filename)
      raise ConfigFileError, "There is no config file at #{filename}"
    end

    def shopify_api_latest_version(config)
      public_versions = query_shopify_api_versions(config)
      if public_versions.empty?
        puts "\nCannot automatically set the latest Shopify API version. You need to specify it manually\n"
      else
        public_versions.select { |version| version["supported"] }.map { |version| version["handle"] }.sort.last
      end
    end
    
    def query_shopify_api_versions(config)
      uri = URI.parse("https://#{config['domain']}/admin/api/graphql.json")
      request = Net::HTTP::Post.new(uri)
      request.content_type = "application/graphql"
      request["X-Shopify-Access-Token"] = config['password'] 
      request.body = "
        {
          publicApiVersions {
            handle
            supported
            displayName
          }
        }
      "

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      response.code.to_i == 200 ? JSON.parse(response.body)["data"]["publicApiVersions"] : Array.new
    end
  end
end
