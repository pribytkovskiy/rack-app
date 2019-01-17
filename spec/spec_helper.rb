require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
  minimum_coverage 90
end
require 'capybara/rspec'
require 'bundler/setup'
require 'rack/test'
require_relative '../autoload'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.example_status_persistence_file_path = '.rspec_status'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
