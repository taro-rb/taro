module Taro::Types
  Dir[File.join(__dir__, "types", "*.rb")].each { |f| require f }
end
