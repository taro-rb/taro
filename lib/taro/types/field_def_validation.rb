module Taro::Types::FieldDefValidation
  private

  def validate
    validate_name
    validate_null
    validate_required
    validate_required_default_conflict
    validate_type_key
  end

  def validate_name
    name.is_a?(Symbol) || raise(Taro::ArgumentError, <<~MSG)
      field name must be a Symbol, got #{name.class} at #{defined_at}
    MSG
  end

  def validate_null
    if attributes.key?(:null)
      [true, false].include?(attributes[:null]) || raise(Taro::ArgumentError, <<~MSG)
        null has to be specified as true or false for field #{name} at #{defined_at}"
      MSG
    elsif Taro.config.default_value_for_null.nil?
      raise(Taro::ArgumentError, <<~MSG)
        null has to be specified for field #{name} at #{defined_at} because there is no default
      MSG
    end
  end

  def validate_required
    if attributes.key?(:required)
      [true, false].include?(attributes[:required]) || raise(Taro::ArgumentError, <<~MSG)
        required has to be specified as true or false for field #{name} at #{defined_at}
      MSG
    elsif Taro.config.default_value_for_required.nil?
      raise(Taro::ArgumentError, <<~MSG)
        required has to be specified for field #{name} at #{defined_at} because there is no default
      MSG
    end
  end

  def validate_required_default_conflict
    return unless attributes[:required] && attributes.key?(:default)

    raise(Taro::ArgumentError, <<~MSG)
      required: true cannot be combined with a default for field #{name} at #{defined_at}
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
