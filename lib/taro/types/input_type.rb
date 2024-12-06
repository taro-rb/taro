require_relative 'object_type'

# Abstract base class for input types, i.e. types without response rendering.
class Taro::Types::InputType < Taro::Types::ObjectType
  def coerce_response
    response_error "#{self.class.name} is an InputType and cannot be used as response type"
  end
end
