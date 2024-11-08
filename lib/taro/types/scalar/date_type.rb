class Taro::Types::Scalar::DateType < Taro::Types::ScalarType
  self.description = 'Represents a date as Date on the server side and UNIX timestamp (integer) on the client side.'
  self.openapi_type = :integer

  def coerce_input
    Time.at(object).to_date if object.instance_of?(Integer)
  end

  def coerce_response
    case object
    when Date, DateTime, Time then object.to_date.strftime('%s').to_i
    when Integer              then Time.at(object).to_date.strftime('%s').to_i
    end
  end
end
