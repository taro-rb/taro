class Taro::Types::Scalar::StringType < Taro::Types::ScalarType
  self.openapi_type = :string

  def coerce_input
    object.instance_of?(String) ? object : input_error('must be a String')
  end

  def coerce_response
    case object
    when String then object
    when Symbol then object.to_s
    else response_error('must be a String or Symbol')
    end
  end
end
