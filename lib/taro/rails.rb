# :nocov:
return unless defined?(::Rails)
# :nocov:

module Taro::Rails
  Dir[File.join(__dir__, "rails", "*.rb")].each { |f| require f }

  extend ActiveDeclarations
  extend DeclarationBuffer

  def self.reset
    declarations.clear
    RouteFinder.clear_cache
  end
end
