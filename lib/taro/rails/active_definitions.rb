module Taro::Rails::ActiveDefinitions
  def apply(definition:, controller_class:, action_name:)
    (definitions[controller_class] ||= {})[action_name] = definition
    Taro::Rails::ParamParsing.install(controller_class:, action_name:)
  end

  def definitions
    @definitions ||= {}
  end
end
