# Abstract class.
class Taro::Types::EnumType < Taro::Types::BaseType
  extend Taro::Types::Shared::ItemType

  def self.value(value)
    self.item_type = Taro::Types::Coercion.call(type: value.class.name)
    @openapi_type ||= item_type.openapi_type
    values << value
  end

  def self.values
    @values ||= []
  end

  def coerce_input
    self.class.raise_if_empty_enum
    value = self.class.item_type.new(object).coerce_input
    if self.class.values.include?(value)
      value
    else
      input_error("must be #{self.class.values.map(&:inspect).join(' or ')}")
    end
  end

  def coerce_response
    self.class.raise_if_empty_enum
    value = self.class.item_type.new(object).cached_coerce_response
    if self.class.values.include?(value)
      value
    else
      response_error("must be #{self.class.values.map(&:inspect).join(' or ')}")
    end
  end

  def self.raise_if_empty_enum
    values.empty? && raise(Taro::RuntimeError, "Enum #{self} has no values")
  end

  def self.inherited(subclass)
    subclass.instance_variable_set(:@values, values.dup)
    super
  end
end
