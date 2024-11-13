# :nocov:
return unless defined?(::Rails)
# :nocov:

module Taro::Rails
  Dir[File.join(__dir__, "rails", "*.rb")].each { |f| require f }

  extend ActiveDeclarations
  extend DeclarationBuffer

  def self.reset
    buffered_declarations.clear
    declarations_map.clear
    RouteFinder.clear_cache
    Taro::Types::BaseType.rendering = nil
    Taro::Types::BaseType.used_in_response = nil
  end
end
