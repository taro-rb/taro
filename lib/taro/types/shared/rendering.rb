# The `::render` method is intended for use in controllers.
# It uses a type to turn an object into a response hash.
# It may be overridden by special types (e.g. PageType).
module Taro::Types::Shared::Rendering
  def render(object)
    new(object).coerce_response
  end

  def response_types
    @response_types
  end

  def response_types=(types)
    @response_types = types
  end

  def input_types
    @input_types
  end

  def input_types=(types)
    @input_types = types
  end
end
