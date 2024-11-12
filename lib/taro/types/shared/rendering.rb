# The `::render` method is intended for use in controllers.
# Special types (e.g. PageType) may accept kwargs for `#coerce_response`.
module Taro::Types::Shared::Rendering
  def render(object, opts = {})
    if (prev = rendering)
      raise Taro::RuntimeError, <<~MSG
        Type.render should only be called once per request.
        (First called on #{prev}, then on #{self}.)
      MSG
    end

    result = new(object).coerce_response(**opts)

    # Only mark this as the used type if coercion worked so that
    # rescue_from can be used to render another type.
    self.rendering = self

    result
  end

  def rendering=(value)
    ActiveSupport::IsolatedExecutionState[:taro_type_rendering] = value
  end

  def rendering
    ActiveSupport::IsolatedExecutionState[:taro_type_rendering]
  end

  def used_in_response=(value)
    ActiveSupport::IsolatedExecutionState[:taro_type_used_in_response] = value
  end

  def used_in_response
    ActiveSupport::IsolatedExecutionState[:taro_type_used_in_response]
  end
end
