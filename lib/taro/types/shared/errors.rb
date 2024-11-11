module Taro::Types::Shared::Errors
  def input_error(msg)
    raise Taro::InputError, coerce_error_message(msg)
  end

  def response_error(msg)
    raise Taro::ResponseError, coerce_error_message(msg)
  end

  def coerce_error_message(msg)
    "#{object.inspect} (#{object.class}) is not valid as #{self.class}: #{msg}"
  end
end
