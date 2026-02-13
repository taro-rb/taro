require_relative 'field_def_validation'

# Lazily-evaluated field definition.
class Taro::Types::FieldDef
  include Taro::Types::FieldDefValidation

  attr_reader :attributes, :defined_at

  def initialize(defined_at: nil, **attributes)
    @attributes = attributes
    @defined_at = defined_at
    validate
  end

  def evaluate
    Taro::Types::Field.new(
      **attributes.except(*Taro::Types::Coercion.keys),
      defined_at:,
      type: Taro::Types::Coercion.call(attributes),
    )
  end

  def name
    attributes[:name]
  end

  def ==(other)
    other.is_a?(self.class) && attributes == other.attributes
  end
end
