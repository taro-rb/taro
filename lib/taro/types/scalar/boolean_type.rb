class Taro::Types::Scalar::BooleanType < Taro::Types::ScalarType
  self.openapi_type = :boolean

  def coerce_input
    object if object == true || object == false
  end

  def coerce_response
    object if object == true || object == false
  end
end

# define shortcut for use as field type
Taro::Types::BaseType::Boolean = Taro::Types::Scalar::BooleanType
