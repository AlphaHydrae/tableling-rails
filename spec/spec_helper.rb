# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'database_cleaner'
require 'factory_girl'

DatabaseCleaner.strategy = :truncation
Capybara.default_driver = :selenium
FactoryGirl.find_definitions

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

module TestServerHelper
  def visit_test_server *args
    args.unshift test_server_root_url
    visit URI.join(*args).to_s
  end

  def test_server_root_url
    "http://localhost:#{RSpec.configuration.test_server_port}"
  end
end

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.include FactoryGirl::Syntax::Methods

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Test server for capybara tests
  # Skip it for fast specs
=begin
  unless config.try(:exclusion_filter).try(:[], :type) == 'request'

    # Test server settings
    config.add_setting :test_server_wait
    config.add_setting :test_server_port
    config.test_server_wait = 3
    config.test_server_port = 3001
    config.include TestServerHelper

    # Start test server before all tests
    config.before :suite do
      puts
      port = config.test_server_port
      wait = config.test_server_wait
      puts Paint["Starting test server...", :magenta]
      raise 'Could not start test server' unless system "bundle exec thin start -e test -p #{port} -d"
      puts Paint["Waiting #{wait} seconds for test server to start...", :magenta]
      sleep wait
      puts Paint["Successfully started test server on port #{port}.", :cyan, :bold]
    end

    # Stop test server after all tests
    config.after :suite do
      puts
      puts Paint["Stopping test server...", :magenta]
      raise 'Could not stop test server' unless system "bundle exec thin stop -e test"
      puts Paint["Successfully stopped test server.", :cyan, :bold]
    end
  end
=end
end
