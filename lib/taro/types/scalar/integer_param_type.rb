# Relaxed Integer type for use with path & query params,
# which Rails provides as Strings.
class Taro::Types::Scalar::IntegerParamType < Taro::Types::ScalarType
  self.openapi_type = :integer

  def coerce_input
    if object.is_a?(Integer)
      object
    elsif object.is_a?(String) && object.match?(/\A\d+\z/)
      object.to_i
    else
      input_error('must be an Integer')
    end
  end
end
