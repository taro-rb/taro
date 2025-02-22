require_relative 'field_validation'

Taro::Types::Field = Data.define(:name, :type, :null, :method, :default, :enum, :defined_at, :desc, :deprecated) do
  include Taro::Types::FieldValidation
  include Taro::Types::Shared::Errors
  include Taro::Types::Shared::TypeClass

  def initialize(name:, type:, null:, method: name, default: Taro::None, enum: nil, defined_at: nil, desc: nil, deprecated: nil)
    enum = coerce_to_enum(enum)
    super(name:, type:, null:, method:, default:, enum:, defined_at:, desc:, deprecated:)
  end

  def value_for_input(object)
    value = object[name] if object
    value = coerce_value(value, true)
    validated_value(value)
  end

  def value_for_response(object, context: nil, object_is_hash: true)
    value = retrieve_response_value(object, context, object_is_hash)
    value = coerce_value(value, false)
    validated_value(value, false)
  end

  def default_specified?
    !default.equal?(Taro::None)
  end

  def openapi_type
    type.openapi_type
  end

  private

  def coerce_to_enum(arg)
    return if arg.nil?

    enum = arg.to_a
    test = Class.new(Taro::Types::EnumType) { arg.each { |v| value(v) } }
    test.raise_if_empty_enum
    enum
  end

  def retrieve_response_value(object, context, object_is_hash)
    if context&.resolve?(method)
      context.public_send(method)
    elsif object_is_hash
      retrieve_hash_value(object)
    elsif object.respond_to?(method, true)
      object.public_send(method)
    else
      response_error "No such method or resolver `:#{method}`", object
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
    return if value.nil? && null
    return default if value.nil? && default_specified?

    type_obj = type.new(value)
    from_input ? type_obj.coerce_input : type_obj.cached_coerce_response
  rescue Taro::ValidationError => e
    reraise_recursively_with_path_info(e)
  end

  def reraise_recursively_with_path_info(error)
    msg =
      error
      .message
      .sub(/ at `\K/, "#{name}.")
      .sub(/(is not valid as [^`]+)(?=: )/, "\\1 at `#{name}`")

    raise error.class.new(msg, error.object, error.origin)
  end
end
