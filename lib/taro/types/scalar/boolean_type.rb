class Taro::Types::Scalar::BooleanType < Taro::Types::ScalarType
  self.openapi_type = :boolean

  def coerce_input
    if object == true || object == false
      object
    else
      input_error('must be true or false')
    end
  end

  def coerce_response
    if object == true || object == false
      object
    else
      response_error('must be true or false')
    end
  end
end
