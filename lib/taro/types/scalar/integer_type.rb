class Taro::Types::Scalar::IntegerType < Taro::Types::ScalarType
  self.openapi_type = :integer

  def coerce_input
    object.instance_of?(Integer) ? object : input_error('must be an Integer')
  end

  def coerce_response
    object.instance_of?(Integer) ? object : response_error('must be an Integer')
  end
end
