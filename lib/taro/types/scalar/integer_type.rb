class Taro::Types::Scalar::IntegerType < Taro::Types::ScalarType
  self.openapi_type = :integer
  self.response_types = [Integer]
  self.input_types = [Integer]

  def coerce_input
    object if object.instance_of?(Integer)
  end

  def coerce_response
    object if object.instance_of?(Integer)
  end
end
