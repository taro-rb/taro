# Buffers api declarations in rails controllers (e.g. `accepts MyType`)
# until the next action method is defined (e.g. `def create`).
module Taro::Rails::DeclarationBuffer
  def buffered_declaration(controller_class)
    buffered_declarations[controller_class] ||= Taro::Rails::Declaration.new
  end

  def buffered_declarations
    @buffered_declarations ||= {}
  end

  def apply_buffered_declaration(controller_class, action_name)
    declaration = pop_buffered_declaration(controller_class)
    return unless declaration

    routes = Taro::Rails::RouteFinder.call(controller_class:, action_name:)
    routes.any? || raise_missing_route(controller_class, action_name)

    declaration.routes = routes
    Taro::Rails.apply(declaration:, controller_class:, action_name:)
  end

  def pop_buffered_declaration(controller_class)
    buffered_declarations.delete(controller_class)
  end

  def raise_missing_route(controller_class, action_name)
    raise Taro::Error, <<~MSG
      Found no route that points to #{controller_class}##{action_name}.
      This might be a bug in Taro. If you really don't have a route
      for this action, we recommend you comment out the api declaration.
    MSG
  end
end
