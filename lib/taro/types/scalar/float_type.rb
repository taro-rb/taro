class Taro::Types::Scalar::FloatType < Taro::Types::ScalarType
  self.openapi_type = :number
  self.response_types = [Float]

  def coerce_input
    object if object.instance_of?(Float)
  end

  def coerce_response
    case object
    when Float   then object
    when Integer then object.to_f
    end
  end
end
