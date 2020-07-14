$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name = %q{shopify_cli}
  s.version = "1.0.5"
  s.author = "Shopify"

  s.summary = %q{Deprecated! Please use the `shopify_api_console` gem.}
  s.description = %q{}
  s.homepage = %q{https://github.com/Shopify/shopify_api_console}
  s.metadata["allowed_push_host"] = "https://rubygems.org"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.rdoc_options = ["--charset=UTF-8"]
  s.license = 'MIT'

  dev_dependencies = [['rake']]

  if s.respond_to?(:add_development_dependency)
    dev_dependencies.each { |dep| s.add_development_dependency(*dep) }
  else
    dev_dependencies.each { |dep| s.add_dependency(*dep) }
  end
end
