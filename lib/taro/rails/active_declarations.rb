module Taro::Rails::ActiveDeclarations
  def apply(declaration:, controller_class:, action_name:)
    (declarations_map[controller_class] ||= {})[action_name] = declaration
    Taro::Rails::ParamParsing.install(controller_class:, action_name:)
    Taro::Rails::ResponseValidation.install(controller_class:)
  end

  def declarations_map
    @declarations_map ||= {}
  end

  def declarations
    declarations_map.values.flat_map(&:values)
  end

  def declaration_for(controller)
    declarations_map[controller.class].to_h[controller.action_name.to_sym]
  end
end
