# Lazily-evaluated field definition.
class Taro::Types::FieldDef
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

  private

  def validate
    validate_name
    validate_null
    validate_type_key
  end

  def validate_name
    name.is_a?(Symbol) || raise(Taro::ArgumentError, <<~MSG)
      field name must be a Symbol, got #{name.class} at #{defined_at}
    MSG
  end

  def validate_null
    [true, false].include?(attributes[:null]) || raise(Taro::ArgumentError, <<~MSG)
      null has to be specified as true or false for field #{name} at #{defined_at}"
    MSG
  end

  def validate_type_key
    attributes[type_key].class == String || raise(Taro::ArgumentError, <<~MSG)
      #{type_key} must be a String for field #{name} at #{defined_at}
    MSG
  end

  def type_key
    possible_keys = Taro::Types::Coercion.keys
    keys = attributes.keys & possible_keys
    keys.size == 1 || raise(Taro::ArgumentError, <<~MSG)
      Exactly one of #{possible_keys.join(', ')} must be given
      for field #{name} at #{defined_at}
    MSG
    keys.first
  end
end
