module Taro::Types::Shared
  Dir[File.join(__dir__, "shared", "*.rb")].each { |f| require f }
end
