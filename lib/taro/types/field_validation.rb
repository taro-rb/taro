module Taro::Types::FieldValidation
  # Validate the value against the field properties. This method will raise
  # a Taro::RuntimeError if the value is not matching.
  def validated_value(value)
    validate_null_and_ok?(value)
    validate_enum_inclusion(value)
    value
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
end
