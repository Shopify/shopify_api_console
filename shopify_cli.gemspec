# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'shopify_cli'

Gem::Specification.new do |s|
  s.name = %q{shopify_cli}
  s.version = ShopifyCLI::VERSION
  s.author = "Shopify"

  s.summary = %q{The Shopify CLI gem is a tool for accessing the Shopify admin REST web services from the console}
  s.description = %q{}
  s.email = %q{developers@shopify.com}
  s.homepage = %q{http://www.shopify.com/partners/apps}

  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.rdoc_options = ["--charset=UTF-8"]
  s.license = 'MIT'

  s.add_dependency("shopify_api")
  s.add_dependency("thor", "~> 0.18.1")
  s.add_dependency("pry", ">= 0.9.12.6")

  dev_dependencies = [['mocha', '>= 0.9.8'],
                      ['fakeweb'], 
                      ['minitest', '~> 4.0'],
                      ['rake']
  ]

  if s.respond_to?(:add_development_dependency)
    dev_dependencies.each { |dep| s.add_development_dependency(*dep) }
  else
    dev_dependencies.each { |dep| s.add_dependency(*dep) }
  end
end
