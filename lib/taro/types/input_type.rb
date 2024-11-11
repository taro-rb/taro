# Abstract base class for input types, i.e. types without response rendering.
class Taro::Types::InputType < Taro::Types::BaseType
  require_relative "shared"
  extend Taro::Types::Shared::Fields
  include Taro::Types::Shared::CustomFieldResolvers
  include Taro::Types::Shared::ObjectCoercion

  self.openapi_type = :object
  self.input_types = [Hash, ActiveSupport::HashWithIndifferentAccess]

  def self.inherited(subclass)
    subclass.instance_variable_set(:@input_types, [Hash, ActiveSupport::HashWithIndifferentAccess])
    super
  end

  def coerce_response
    raise Taro::RuntimeError, 'InputTypes cannot be used as response types'
  end
end
