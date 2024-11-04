# Abstract class.
class Taro::Types::EnumType < Taro::Types::BaseType
  require_relative 'enum_type/value_validation'
  extend ValueValidation

  def self.value(value)
    values << validate_value(value)
  end

  def self.values
    @values ||= []
  end

  def coerce_input
    self.class.raise_if_empty_enum
    value = self.class.value_type.new(object).coerce_input
    value if self.class.values.include?(value)
  end

  def coerce_response
    self.class.raise_if_empty_enum
    value = self.class.value_type.new(object).coerce_response
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
