lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bump/cli/version"

Gem::Specification.new do |spec|
  spec.name = "bump-cli"
  spec.version = Bump::CLI::VERSION
  spec.authors = ["Mehdi Lahmam", "Sébastien Charrier"]
  spec.email = ["mehdi@lahmam.com", "sebastien@bump.sh"]

  spec.summary = "Bump.sh CLI"
  spec.description = "Bump.sh CLI to interact with the API"
  spec.homepage = "https://bump.sh"
  spec.license = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["source_code_uri"] = "https://github.com/bump-sh/bump-cli"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3"

  spec.add_dependency "dry-cli", "~> 0"
  spec.add_dependency "http", ">= 3"

  spec.add_development_dependency "bundler", ">= 1", "< 3"
  spec.add_development_dependency "byebug", "~> 11"
  spec.add_development_dependency "climate_control", "~> 0"
  spec.add_development_dependency "rake", "~> 13"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "webmock", "~> 3"
end
