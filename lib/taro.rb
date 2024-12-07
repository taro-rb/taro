module Taro
  Dir[File.join(__dir__, "taro", "*.rb")].each { |f| require_relative f }

  def self.reset
    declarations.reset
    Taro::Types::BaseType.last_render = nil
  end
end
