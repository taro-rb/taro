module Taro::Rails::ActiveDeclarations
  def apply(declaration:, controller_class:, action_name:)
    Taro.declarations["#{controller_class.name}##{action_name}"] = declaration
    Taro::Rails::ParamParsing.install(controller_class:, action_name:)
    Taro::Rails::ResponseValidation.install(controller_class:)
  end

  def declaration_for(controller)
    Taro.declarations["#{controller.class.name}##{controller.action_name}"]
  end
end
