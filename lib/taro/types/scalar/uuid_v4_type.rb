class Taro::Types::Scalar::UUIDv4Type < Taro::Types::ScalarType
  self.desc = "A UUID v4 string"
  self.openapi_type = :string

  PATTERN = /\A\h{8}-?(?:\h{4}-?){3}\h{12}\z/

  def coerce_input
    if object.is_a?(String) && object.match?(PATTERN)
      object
    else
      input_error("must be a UUID v4 string")
    end
  end

  def coerce_response
    if object.is_a?(String) && object.match?(PATTERN)
      object
    else
      response_error("must be a UUID v4 string")
    end
  end
end
