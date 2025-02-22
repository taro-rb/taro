# Abstract base class for all types.
#
# Concrete type classes must set `self.openapi_type` and implement
# the `#coerce_input` and `#coerce_response` methods.
#
# Instances of types are initialized with the object that they represent.
# The object is a parameter hash for inputs and a manually passed hash
# or object when rendering a response.
#
# Using Struct instead of Data here for performance reasons:
# https://bugs.ruby-lang.org/issues/19693
Taro::Types::BaseType = Struct.new(:object) do
  require_relative "shared"
  extend Taro::Types::Shared::AdditionalProperties
  extend Taro::Types::Shared::Deprecation
  extend Taro::Types::Shared::DerivedTypes
  extend Taro::Types::Shared::Description
  extend Taro::Types::Shared::Equivalence
  extend Taro::Types::Shared::Name
  extend Taro::Types::Shared::OpenAPIName
  extend Taro::Types::Shared::OpenAPIType
  extend Taro::Types::Shared::Rendering
  include Taro::Types::Shared::Caching
  include Taro::Types::Shared::Errors
  include Taro::Types::Shared::TypeClass
end
