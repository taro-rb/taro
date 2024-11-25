class Taro::Types::Scalar::StringType < Taro::Types::ScalarType
  self.openapi_type = :string

  def coerce_input
    object.instance_of?(String) || input_error('must be a String')

    pattern.nil? || pattern.match?(object) ||
      input_error("must match pattern #{pattern.inspect}")

    object
  end

  def coerce_response
    str =
      case object
      when String then object
      when Symbol then object.to_s
      else response_error('must be a String or Symbol')
      end

    pattern.nil? || pattern.match?(str) ||
      response_error("must match pattern #{pattern.inspect}")

    str
  end
end
