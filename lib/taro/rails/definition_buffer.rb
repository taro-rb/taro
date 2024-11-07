# Buffers api definitions in rail controllers (e.g. `accepts MyType`)
# until the next action method is defined (e.g. `def create`).
module Taro::Rails::DefinitionBuffer
  def buffered_definition(controller_class)
    buffered_definitions[controller_class] ||= Taro::Rails::Definition.new
  end

  def buffered_definitions
    @buffered_definitions ||= {}
  end

  def apply_buffered_definition(controller_class, action_name)
    definition = pop_buffered_definition(controller_class)
    return unless definition

    routes = Taro::Rails::RouteFinder.call(controller_class:, action_name:)
    routes.any? || raise_missing_route(controller_class, action_name)

    definition.routes = routes
    Taro::Rails.apply(definition:, controller_class:, action_name:)
  end

  def pop_buffered_definition(controller_class)
    buffered_definitions.delete(controller_class)
  end

  def raise_missing_route(controller_class, action_name)
    raise Taro::Error, <<~MSG
      Found no route that points to #{controller_class}##{action_name}.
      This might be a bug in Taro. If you really don't have a route
      for this action, we recommend you comment out the api declaration.
    MSG
  end
end
