#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

require File.expand_path('../spec/dummy/config/application', __FILE__)
require 'rspec-rails'
Dummy::Application.load_tasks

require 'rake-version'
RakeVersion::Tasks.new do |v|
  v.copy 'lib/tableling-rails/version.rb'
end

task :default => :spec
