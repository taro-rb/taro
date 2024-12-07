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

    msg = 'field is not nullable'
    for_input ? input_error(msg, value) : response_error(msg, value)
  end

  def validate_enum_inclusion(value, for_input)
    return if enum.nil? || null && value.nil? || enum.include?(value)

    msg = "field expects one of #{enum.inspect}, got #{value.inspect}"
    for_input ? input_error(msg, value) : response_error(msg, value)
  end
end
