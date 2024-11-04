module Taro
  Dir[File.join(__dir__, "taro", "*.rb")].each { |f| require f }
end
