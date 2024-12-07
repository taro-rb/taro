module Taro::Types::Shared::Errors
  def input_error(msg, value = object)
    raise Taro::InputError.new(coerce_error_message(msg, value), value, self)
  end

  def response_error(msg, value = object)
    raise Taro::ResponseError.new(coerce_error_message(msg, value), value, self)
  end

  def coerce_error_message(msg, value)
    type_class = is_a?(Taro::Types::Field) ? self.type : self.class
    type_desc = type_class.name.sub(/^Taro::Types::.*?([^:]+)$/, '\1')
    "#{value.class} is not valid as #{type_desc}: #{msg}"
  end
end
