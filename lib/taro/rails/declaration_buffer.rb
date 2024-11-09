# Buffers api declarations in rails controllers (e.g. `param :foo, ...`)
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

    add_openapi_name_for_input(declaration, controller_class, action_name)
    add_routes(declaration, controller_class, action_name)

    Taro::Rails.apply(declaration:, controller_class:, action_name:)
  end

  # TODO: this changes when the controller class is renamed, we might need a way to set it
  # independently, perhaps as kwarg to `::api`? (Would need a uniqueness check then.)
  def add_openapi_name_for_input(declaration, controller_class, action_name)
    declaration.params.openapi_name =
      "#{controller_class.name.chomp('Controller').sub('::', '_')}_#{action_name}_Input"
  end

  def add_routes(declaration, controller_class, action_name)
    routes = Taro::Rails::RouteFinder.call(controller_class:, action_name:)
    routes.any? || raise_missing_route(controller_class, action_name)
    declaration.routes = routes
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
