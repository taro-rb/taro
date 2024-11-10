class Taro::Types::Scalar::TimestampType < Taro::Types::ScalarType
  self.description = 'Represents a time as Time on the server side and UNIX timestamp (integer) on the client side.'
  self.openapi_type = :integer
  self.response_types = [Integer]

  def coerce_input
    Time.at(object) if object.instance_of?(Integer)
  end

  def coerce_response
    case object
    when Date, DateTime, Time then object.strftime('%s').to_i
    when Integer              then object
    end
  end
end
