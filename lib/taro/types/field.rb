require_relative 'field_value_validation'

Taro::Types::Field = Data.define(:name, :type, :null, :required, :resolver, :default, :enum, :defined_at, :desc, :deprecated) do
  include Taro::Types::FieldValueValidation
  include Taro::Types::Shared::Errors
  include Taro::Types::Shared::TypeClass

  def initialize(
    name:,
    type:,
    method: name, # note: `method` is stored as #resolver to avoid overriding Object#method
    null: Taro.config.default_value_for_null,
    default: Taro::None,
    required: default == Taro::None ? Taro.config.default_value_for_required : false,
    enum: nil,
    defined_at: nil,
    desc: nil,
    deprecated: nil
  )
    enum = coerce_to_enum(enum)
    super(name:, type:, null: !!null, required: !!required, resolver: method, default:, enum:, defined_at:, desc:, deprecated:)
  end

  def value_for_input(object)
    unless object&.key?(name)
      fail_if_required
      return default_specified? ? default : Taro::None
    end
    value = object[name]
    value = coerce_value(value, true)
    validated_value(value)
  rescue Taro::ValidationError => e
    reraise_recursively_with_path_info(e)
  end

  def value_for_response(object, context: nil, object_is_hash: true)
    value = retrieve_response_value(object, context, object_is_hash)
    value = coerce_value(value, false)
    validated_value(value, false)
  rescue Taro::ValidationError => e
    reraise_recursively_with_path_info(e)
  end

  def default_specified?
    !default.equal?(Taro::None)
  end

  def openapi_type
    type.openapi_type
  end

  def openapi_format
    type.openapi_format
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
    if context&.resolve?(resolver)
      context.public_send(resolver)
    elsif object_is_hash
      retrieve_hash_value(object)
    elsif object.respond_to?(resolver, true)
      object.public_send(resolver)
    else
      response_error "No such method or resolver `:#{resolver}`", object
    end
  end

  def retrieve_hash_value(object)
    if object.key?(resolver.to_s)
      object[resolver.to_s]
    else
      object[resolver]
    end
  end

  def coerce_value(value, from_input)
    return if value.nil? && null
    return default if value.nil? && default_specified?

    type_obj = type.new(value)
    from_input ? type_obj.coerce_input : type_obj.cached_coerce_response
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
