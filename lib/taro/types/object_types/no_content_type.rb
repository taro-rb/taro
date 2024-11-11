class Taro::Types::ObjectTypes::NoContentType < Taro::Types::ObjectType
  self.description = 'An empty response'

  # render takes no arguments in this case
  def self.render
    super(nil)
  end

  def coerce_input
    raise Taro::RuntimeError, 'NoContentType cannot be used as input type'
  end

  def coerce_response
    {}
  end
end
