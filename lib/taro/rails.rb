# :nocov:
return unless defined?(::Rails)
# :nocov:

module Taro::Rails
  Dir[File.join(__dir__, "rails", "*.rb")].each { |f| require f }

  extend ActiveDefinitions
  extend DefinitionBuffer
end
