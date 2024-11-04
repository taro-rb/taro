# Abstract base class for renderable types with fields.
class Taro::Types::ObjectType < Taro::Types::BaseType
  require_relative "shared"
  extend Taro::Types::Shared::Fields
  include Taro::Types::Shared::CustomFieldResolvers
  include Taro::Types::Shared::ObjectCoercion

  self.openapi_type = :object
end
