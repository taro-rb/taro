# Abstract base class for all types.
#
# Concrete type classes must set `self.openapi_type` and implement
# the `#coerce_input` and `#coerce_response` methods.
#
# Instances of types are initialized with the object that they represent.
# The object is a parameter hash for inputs and a manually passed hash
# or object when rendering a response.
Taro::Types::BaseType = Data.define(:object) do
  require_relative "shared"
  extend Taro::Types::Shared::Description
  extend Taro::Types::Shared::Nesting
  extend Taro::Types::Shared::OpenAPIType
  extend Taro::Types::Shared::Rendering
end
