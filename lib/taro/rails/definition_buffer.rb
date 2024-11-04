# Buffers api definitions in rail controllers (e.g. `accepts MyType`)
# until the next action method is defined (e.g. `def create`).
module Taro::Rails::DefinitionBuffer
  def buffered_definition(controller_class)
    buffered_definitions[controller_class] ||= Taro::Rails::Definition.new
  end

  def buffered_definitions
    @buffered_definitions ||= {}
  end

  def apply_buffered_definition(controller_class, method_name)
    definition = pop_buffered_definition(controller_class)
    return unless definition

    Taro::Rails.apply(definition:, controller_class:, method_name:)
  end

  def pop_buffered_definition(controller_class)
    buffered_definitions.delete(controller_class)
  end
end
