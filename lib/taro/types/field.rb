require_relative 'field_validation'

Taro::Types::Field = Data.define(:name, :type, :null, :method, :default, :enum, :defined_at, :desc, :deprecated) do
  include Taro::Types::FieldValidation

  def initialize(name:, type:, null:, method: name, default: :none, enum: nil, defined_at: nil, desc: nil, deprecated: nil)
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
    !default.equal?(:none)
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
      # Note that the ObjectCoercion module rescues this and adds context.
      raise Taro::ResponseError, "No such method or resolver `:#{method}`."
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
    from_input ? type_obj.coerce_input : type_obj.coerce_response
  end
end
