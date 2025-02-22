module Taro::Types::Shared::Rendering
  # The `::render` method is intended for use in controllers.
  # Overrides of this method must call super.
  def render(object, cache_attrs = {})
    result = Taro::Cache.call(object, **cache_attrs) do
      new(object).cached_coerce_response
    end
    self.last_render = [type_class, result.__id__]
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
