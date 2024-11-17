# Abstract base class for List types (arrays in OpenAPI terms).
# Unlike other types, this one should not be manually inherited from,
# but is used indirectly via `array_of: SomeType`.
class Taro::Types::ListType < Taro::Types::BaseType
  extend Taro::Types::Shared::ItemType

  self.openapi_type = :array

  def coerce_input
    object.instance_of?(Array) || input_error('must be an Array')

    item_type = self.class.item_type
    object.map { |el| item_type.new(el).coerce_input }
  end

  def coerce_response
    object.respond_to?(:map) || response_error('must be an Enumerable')

    item_type = self.class.item_type
    object.map { |el| item_type.new(el).coerce_response }
  end

  define_derived_type :array, 'Taro::Types::ListType'
end
