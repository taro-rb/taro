class Taro::Types::Scalar::StringType < Taro::Types::ScalarType
  self.openapi_type = :string

  def coerce_input
    object if object.instance_of?(String)
  end

  def coerce_response
    case object
    when String then object
    when Symbol then object.to_s
    end
  end
end
