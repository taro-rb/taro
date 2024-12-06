module Taro::Rails::Generators
  Dir[File.join(__dir__, 'generators', '**', '*.rb')].each { |f| require_relative f }
end
