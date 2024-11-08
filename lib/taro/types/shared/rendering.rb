# The `::render` method is intended for use in controllers.
# It uses a type to turn an object into a response hash.
# It may be overridden by special types (e.g. PageType).
module Taro::Types::Shared::Rendering
  def render(object)
    result = new(object).render

    if Taro.config.response_nesting && nesting
      { nesting => result }
    else
      result
    end
  end
end
