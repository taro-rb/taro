class Taro::Types::ObjectTypes::NoContentType < Taro::Types::ObjectType
  self.desc = 'An empty response'
  self.openapi_name = 'NoContent'

  # render takes no arguments in this case
  def self.render
    super(nil)
  end

  def coerce_input
    input_error 'NoContentType cannot be used as input type'
  end

  def coerce_response
    {}
  end
end
