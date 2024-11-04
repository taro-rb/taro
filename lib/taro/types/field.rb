Taro::Types::Field = Data.define(:name, :type, :null, :method, :default, :defined_at, :description) do
  def initialize(name:, type:, null:, method: name, default: nil, defined_at: nil, description: nil)
    validate_null_arg(null)
    type = Taro::Types::CoerceToType.call(type)
    super(name:, type:, null:, method:, default:, defined_at:, description:)
  end

  def extract_value(object, context: nil, from_input: true, from_hash: true)
    value = retrieve_value(object, context, from_hash)
    coerce_value(object, value, from_input)
  end

  private

  def validate_null_arg(arg)
    arg == true || arg == false ||
      raise(Taro::ArgumentError, 'null: must be true or false')
  end

  def retrieve_value(object, context, from_hash)
    if context&.resolve?(method)
      context.public_send(method)
    elsif from_hash
      retrieve_value_from_hash(object)
    elsif object.respond_to?(method, false)
      object.public_send(method)
    else
      raise_coercion_error(object)
    end
  end

  def retrieve_value_from_hash(object)
    if object.key?(method.to_s)
      object[method.to_s]
    else
      object[method]
    end
  end

  def coerce_value(object, value, from_input)
    return default if value.nil? && !default.nil?
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
      Failed to coerce value #{object.inspect} for field #{name} with :#{method}.
      It is not a valid #{type} value.
    MSG
  end
end
