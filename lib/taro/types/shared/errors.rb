module Taro::Types::Shared::Errors
  def input_error(msg)
    raise Taro::InputError, coerce_error_message(msg)
  end

  def response_error(msg)
    raise Taro::ResponseError, coerce_error_message(msg)
  end

  def coerce_error_message(msg)
    type_desc = (self.class.name || self.class.superclass.name)
                .sub(/^Taro::Types::.*?([^:]+)Type$/, '\1')
    "#{object.class} is not valid as #{type_desc}: #{msg}"
  end
end
