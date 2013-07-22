$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tableling-rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tableling-rails"
  s.version     = Tableling::VERSION
  s.authors     = ["Simon Oulevay"]
  s.email       = ["hydrae.alpha@gmail.com"]
  s.homepage    = "https://github.com/AlphaHydrae/tableling-rails"
  s.summary     = "Tableling gem for Ruby on Rails."
  s.description = "Javascript assets for the latest Tableling release and active record extensions to easily generate table data."
  s.licenses    = ["MIT"]

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2"
end
