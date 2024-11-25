class Taro::Types::Scalar::ISO8601DateTimeType < Taro::Types::ScalarType
  self.desc = 'Represents a time as DateTime in ISO8601 format.'
  self.openapi_name = 'ISO8601DateTime'
  self.openapi_type = :string
  self.pattern = /\A\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])T([01]\d|2[0-3]):[0-5]\d:[0-5]\d(Z|[+-](0[0-9]|1[0-4]):[0-5]\d)\z/

  def coerce_input
    if object.instance_of?(String) && object.match?(pattern)
      DateTime.iso8601(object)
    else
      input_error("must be a ISO8601 formatted string")
    end
  end

  def coerce_response
    case object
    when Date
      object.to_datetime.utc.iso8601
    when DateTime, Time
      object.utc.iso8601
    else
      response_error("must be a Time, Date, or DateTime")
    end
  end
end
