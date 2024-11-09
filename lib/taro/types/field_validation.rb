module Taro::Types::FieldValidation
  # Validate the value against the field properties. This method will raise
  # a Taro::RuntimeError if the value is not matching.
  def validate!(object)
    value = object[name]

    validate_null_and_ok?(object, value)
    validate_value_and_type(value)
    validate_enum_inclusion(value)
  end

  private

  def validate_null_and_ok?(object, value)
    return false unless value.nil?
    return true if null

    raise Taro::ValidationError, <<~MSG
      Field #{name} is not nullable (tried :#{method} on #{object})
    MSG
  end

  def validate_enum_inclusion(value)
    return if enum.nil? || enum.include?(value)

    raise Taro::ValidationError, <<~MSG
      Field #{name} has an invalid value #{value.inspect} (expected one of #{enum.inspect})
    MSG
  end

  def validate_value_and_type(value)
    expected_value = type.new(value).coerce_input
    return if value === expected_value

    raise Taro::ValidationError, <<~MSG
      Field #{name} has an invalid value #{value.inspect} (expected #{expected_value.inspect})
    MSG
  end
end
