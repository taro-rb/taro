Taro::Types::Field = Data.define(:name, :type, :null, :method, :default, :enum, :defined_at, :description) do
  def initialize(name:, type:, null:, method: name, default: :none, enum: nil, defined_at: nil, description: nil)
    enum = coerce_to_enum(enum)
    super(name:, type:, null:, method:, default:, enum:, defined_at:, description:)
  end

  def extract_value(object, context: nil, from_input: true, object_is_hash: true)
    value = retrieve_value(object, context, object_is_hash)
    coerce_value(object, value, from_input)
  end

  def default_specified?
    !default.equal?(:none)
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
    if context&.resolve?(method)
      context.public_send(method)
    elsif object_is_hash
      retrieve_hash_value(object)
    elsif object.respond_to?(method, false)
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

  def coerce_value(object, value, from_input)
    return default if value.nil? && default_specified?
    return if null_and_ok?(object, value)

    result = coerce_value_with_type(value, from_input)
    result.nil? && raise_coercion_error(object)
    result
  end

  def coerce_value_with_type(value, from_input)
    if from_input
      type.new(value).coerce_input
    else
      type.new(value).coerce_response
    end
  end

  def null_and_ok?(object, value)
    return false unless value.nil?
    return true if null

    raise Taro::RuntimeError, <<~MSG
      Field #{name} is not nullable (tried :#{method} on #{object})
    MSG
  end

  def raise_coercion_error(object)
    raise Taro::RuntimeError, <<~MSG
      Failed to coerce value #{object.inspect} for field `#{name}` using method/key `:#{method}`.
      It is not a valid #{type} value.
    MSG
  end
end
