class Taro::Types::Scalar::ISO8601DateType < Taro::Types::ScalarType
  self.desc = 'Represents a time as Date in ISO8601 format.'
  self.openapi_type = :string

  PATTERN = /\A\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])\z/

  def coerce_input
    if object.instance_of?(String) && object.match?(PATTERN)
      Date.parse(object)
    else
      input_error("must be a ISO8601 formatted string")
    end
  end

  def coerce_response
    case object
    when Date, DateTime, Time
      object.strftime("%Y-%m-%d")
    else
      response_error("must be a Time, Date, or DateTime")
    end
  end
end
