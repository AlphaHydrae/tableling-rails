$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tableling/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tableling"
  s.version     = Tableling::VERSION
  s.authors     = ["Simon Oulevay"]
  s.email       = ["hydrae.alpha@gmail.com"]
  s.homepage    = "https://github.com/AlphaHydrae/tableling-rails"
  s.summary     = "Async table plugin based on Backbone Marionette."
  s.description = "Async table plugin based on Backbone Marionette."

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.8"

  s.add_development_dependency "sqlite3"
end
