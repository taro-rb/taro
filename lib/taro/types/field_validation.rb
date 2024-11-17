module Taro::Types::FieldValidation
  # Validate the value against the field properties. This method will raise
  # a Taro::InputError or Taro::ResponseError if the value is not matching.
  def validated_value(value, for_input = true)
    validate_null_and_ok?(value, for_input)
    validate_enum_inclusion(value, for_input)
    value
  end

  private

  def validate_null_and_ok?(value, for_input)
    return if null || !value.nil?

    raise for_input ? Taro::InputError : Taro::ResponseError, <<~MSG
      Field #{name} is not nullable (got #{value.inspect})
    MSG
  end

  def validate_enum_inclusion(value, for_input)
    return if enum.nil? || null && value.nil? || enum.include?(value)

    raise for_input ? Taro::InputError : Taro::ResponseError, <<~MSG
      Field #{name} has an invalid value #{value.inspect} (expected one of #{enum.inspect})
    MSG
  end
end
