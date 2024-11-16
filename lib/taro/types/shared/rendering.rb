# The `::render` method is intended for use in controllers.
# Special types (e.g. PageType) may accept kwargs for `#coerce_response`.
module Taro::Types::Shared::Rendering
  def render(object, opts = {})
    result = new(object).coerce_response(**opts)
    self.last_render = [self, result.__id__]
    result
  end

  def last_render=(info)
    ActiveSupport::IsolatedExecutionState[:taro_last_render] = info
  end

  def last_render
    ActiveSupport::IsolatedExecutionState[:taro_last_render]
  end

  # get the last used type for assertions in tests/specs
  def used_in_response
    last_render.to_a.first
  end
end
