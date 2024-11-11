# Abstract base class for input types, i.e. types without response rendering.
class Taro::Types::InputType < Taro::Types::BaseType
  require_relative "shared"
  extend Taro::Types::Shared::Fields
  include Taro::Types::Shared::CustomFieldResolvers
  include Taro::Types::Shared::ObjectCoercion

  self.openapi_type = :object

  def coerce_response
    raise Taro::RuntimeError, 'InputTypes cannot be used as response types'
  end
end
