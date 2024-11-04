module Taro::Rails::ActiveDefinitions
  def apply(definition:, controller_class:, method_name:)
    (definitions[controller_class] ||= {})[method_name] = definition
    Taro::Rails::ParamParsing.install(controller_class:, method_name:)
  end

  def definitions
    @definitions ||= {}
  end
end
