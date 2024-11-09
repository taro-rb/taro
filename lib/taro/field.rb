Taro::Field = Data.define(:name, :type, :null, :method, :default, :enum, :defined_at, :description) do
  # extend Taro::Field::Validation

  def initialize(name:, type:, null:, method: name, default: :none, enum: nil, defined_at: nil, description: nil)
    enum = coerce_to_enum(enum)
    super(name:, type:, null:, method:, default:, enum:, defined_at:, description:)
  end

  def extract_value(object, context: nil, from_input: true, object_is_hash: true)
    value = retrieve_value(object, context, object_is_hash)
    coerce_value(value, from_input)
  end

  def default_specified?
    !default.equal?(:none)
  end

  # TODO move all validation to Taro::Field::Validation module
  # Validate the value against the fields definition. This method will raise
  # a Taro::RuntimeError if the value is not matching.
  def validate!(object)
    value = object[name]

    validate_null_and_ok?(object, value)
    validate_value_and_type(value)
    validate_enum_inclusion(value)
  end

  def openapi_type
    null ? [type.openapi_type, :null] : type.openapi_type
  end

  private

  def coerce_to_enum(arg)
    return if arg.nil?

    enum = arg.to_a
    test = Class.new(Taro::Types::EnumType) { arg.each { |v| value(v) } }
    test.raise_if_empty_enum
    enum
  end

  def retrieve_value(object, context, object_is_hash)
    if object_is_hash
      retrieve_hash_value(object)
    elsif context&.resolve?(method)
      context.public_send(method)
    elsif object.respond_to?(method, true)
      object.public_send(method)
    else
      raise_coercion_error(object)
    end
  end

  def retrieve_hash_value(object)
    if object.key?(method.to_s)
      object[method.to_s]
    else
      object[method]
    end
  end

  def coerce_value(value, from_input)
    return default if value.nil? && default_specified?

    type_obj = type.new(value)
    from_input ? type_obj.coerce_input : type_obj.coerce_response
  end

  # TODO move all validation to Taro::Field::Validation module
  def validate_null_and_ok?(object, value)
    return false unless value.nil?
    return true if null

    raise Taro::ValidationError, <<~MSG
      Field #{name} is not nullable (tried :#{method} on #{object})
    MSG
  end

  # TODO move all validation to Taro::Field::Validation module
  def validate_enum_inclusion(value)
    return if enum.nil? || enum.include?(value)

    raise Taro::ValidationError, <<~MSG
      Field #{name} has an invalid value #{value.inspect} (expected one of #{enum.inspect})
    MSG
  end

  # TODO move all validation to Taro::Field::Validation module
  def validate_value_and_type(value)
    expected_value = type.new(value).coerce_input
    return if value === expected_value

    raise Taro::ValidationError, <<~MSG
      Field #{name} has an invalid value #{value.inspect} (expected #{expected_value.inspect})
    MSG
  end

  def raise_coercion_error(object)
    raise Taro::RuntimeError, <<~MSG
      Failed to coerce value #{object.inspect} for field `#{name}` using method/key `:#{method}`.
      It is not a valid #{type} value.
    MSG
  end
end
