class Taro::Types::Scalar::TimestampType < Taro::Types::ScalarType
  self.desc = 'Represents a time as Time on the server side and UNIX timestamp (integer) on the client side.'
  self.openapi_type = :integer

  def coerce_input
    if object.instance_of?(Integer)
      Time.at(object)
    else
      input_error("must be an Integer")
    end
  end

  def coerce_response
    case object
    when Date, DateTime, Time
      object.strftime('%s').to_i
    when Integer
      object
    else
      response_error("must be a Time, Date, DateTime, or Integer")
    end
  end
end
