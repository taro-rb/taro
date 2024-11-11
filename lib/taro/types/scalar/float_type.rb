class Taro::Types::Scalar::FloatType < Taro::Types::ScalarType
  self.openapi_type = :number

  def coerce_input
    object.instance_of?(Float) ? object : input_error('must be a Float')
  end

  def coerce_response
    case object
    when Float   then object
    when Integer then object.to_f
    else              response_error('must be a Float or Integer')
    end
  end
end
