module Taro::Types::FieldValidation
  # Validate the value against the field properties. This method will raise
  # a Taro::RuntimeError if the value is not matching.
  def valid?(value)
    validate_null_and_ok?(value)
    validate_enum_inclusion(value)
    validate_type(value)
  end

  private

  def validate_null_and_ok?(value)
    return false unless value.nil?
    return true if null

    raise Taro::ValidationError, <<~MSG
      Field #{name} is not nullable (got #{value.inspect})
    MSG
  end

  def validate_enum_inclusion(value)
    return if enum.nil? || enum.include?(value)

    raise Taro::ValidationError, <<~MSG
      Field #{name} has an invalid value #{value.inspect} (expected one of #{enum.inspect})
    MSG
  end

  def validate_type(value)
    return if value.nil?
    return if type.response_types.include?(value.class)

    raise Taro::ValidationError, <<~MSG
      Field #{name} has an invalid type #{value.class.name} (expected #{type.response_types.map(&:name).inspect})
    MSG
  end
end
