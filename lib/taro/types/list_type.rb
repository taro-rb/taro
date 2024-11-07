# Abstract base class for List types (arrays in OpenAPI terms).
# Unlike other types, this one should not be manually inherited from,
# but is used indirectly via `array_of: SomeType`.
class Taro::Types::ListType < Taro::Types::BaseType
  extend Taro::Types::Shared::DerivableType
  extend Taro::Types::Shared::ItemType

  self.openapi_type = :array

  def coerce_input
    return unless object.instance_of?(Array)

    item_type = self.class.item_type
    object.map do |el|
      res = item_type.new(el).coerce_input
      res.nil? ? break : res
    end
  end

  def coerce_response
    item_type = self.class.item_type
    Array(object).map do |el|
      res = item_type.new(el).coerce_response
      res.nil? ? break : res
    end
  end

  def self.default_nesting
    item_type.nesting&.then { |n| "#{n}_list" }
  end
end
