class Taro::Types::Scalar::BooleanType < Taro::Types::ScalarType
  self.openapi_type = :boolean
  self.response_types = [TrueClass, FalseClass]

  def coerce_input
    object if object == true || object == false
  end

  def coerce_response
    object if object == true || object == false
  end
end
