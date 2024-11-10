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

    declaration.finalize(controller_class:, action_name:)

    Taro::Rails.apply(declaration:, controller_class:, action_name:)
  end

  def pop_buffered_declaration(controller_class)
    buffered_declarations.delete(controller_class)
  end
end
