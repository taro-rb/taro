require_relative "support/coverage"
require "rails"
require "taro"
require "debug"
Dir["#{__dir__}/support/**/*.rb"].each { |f| require_relative f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    Taro::Rails.reset
  end
end
