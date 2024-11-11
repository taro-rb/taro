# The `::render` method is intended for use in controllers.
# Special types (e.g. PageType) may accept kwargs for `#coerce_response`.
module Taro::Types::Shared::Rendering
  def render(object, opts = {})
    if (prev = rendered)
      raise Taro::RuntimeError, <<~MSG
        Type.render should only be called once per request.
        (First called on #{prev}, then on #{self}.)
      MSG
    end

    result = new(object).coerce_response(**opts)

    # Only mark this as the used type if coercion worked so that
    # rescue_from can be used to render another type.
    self.rendered = self

    result
  end

  def rendered=(value)
    ActiveSupport::IsolatedExecutionState[:taro_type_rendered] = value
  end

  def rendered
    ActiveSupport::IsolatedExecutionState[:taro_type_rendered]
  end
end
