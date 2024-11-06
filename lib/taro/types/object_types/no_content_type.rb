class Taro::Types::ObjectTypes::NoContentType < Taro::Types::ObjectType
  self.description = 'An empty response'

  # render takes no argument in this case
  def self.render
    {}
  end

  def coerce_input
    raise Taro::RuntimeError, 'NoContentType cannot be used as input type'
  end

  def coerce_response
    object if object == {}
  end
end
