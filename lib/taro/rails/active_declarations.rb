module Taro::Rails::ActiveDeclarations
  def apply(declaration:, controller_class:, action_name:)
    (declarations[controller_class] ||= {})[action_name] = declaration
    Taro::Rails::ParamParsing.install(controller_class:, action_name:)
  end

  def declarations
    @declarations ||= {}
  end
end
