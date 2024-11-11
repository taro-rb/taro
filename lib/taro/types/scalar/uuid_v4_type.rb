class Taro::Types::Scalar::UUIDv4Type < Taro::Types::ScalarType
  self.description = "A UUID v4 string"
  self.openapi_type = :string
  self.response_types = [String]
  self.input_types = [String]

  PATTERN = /\A\h{8}-?(?:\h{4}-?){3}\h{12}\z/

  def coerce_input
    object if object.is_a?(String) && object.match?(PATTERN)
  end

  def coerce_response
    object if object.is_a?(String) && object.match?(PATTERN)
  end
end
