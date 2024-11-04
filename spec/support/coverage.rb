if ENV['CI'] || ARGV.grep(/\w_spec\.rb/).empty? # i.e. if not running individual specs locally
  require 'simplecov'
  SimpleCov.start('rails') do
    enable_coverage :branch
    primary_coverage :branch
  end
  SimpleCov.minimum_coverage line: 100, branch: 100
end
