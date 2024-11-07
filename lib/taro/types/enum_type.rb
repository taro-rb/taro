# Abstract class.
class Taro::Types::EnumType < Taro::Types::BaseType
  extend Taro::Types::Shared::ItemType

  def self.value(value)
    self.item_type = value.class.name
    @openapi_type ||= item_type.openapi_type
    values << value
  end

  def self.values
    @values ||= []
  end

  def coerce_input
    self.class.raise_if_empty_enum
    value = self.class.item_type.new(object).coerce_input
    value if self.class.values.include?(value)
  end

  def coerce_response
    self.class.raise_if_empty_enum
    value = self.class.item_type.new(object).coerce_response
    value if self.class.values.include?(value)
  end

  def self.raise_if_empty_enum
    values.empty? && raise(Taro::RuntimeError, "Enum #{self} has no values")
  end

  def self.inherited(subclass)
    subclass.instance_variable_set(:@values, values.dup)
    super
  end
end
