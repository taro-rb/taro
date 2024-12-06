require_relative 'object_type'

# Abstract base class for response types, i.e. types without input parsing.
class Taro::Types::ResponseType < Taro::Types::ObjectType
  def coerce_input
    input_error "#{self.class.name} is a ResponseType and cannot be used as input type"
  end
end
