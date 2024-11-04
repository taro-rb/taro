module Taro::Rails::ParamParsing
  def self.install(controller_class:, method_name:)
    return unless Taro.config.parse_params

    key = [controller_class, method_name]
    return if installed[key]

    installed[key] = true

    controller_class.before_action(only: method_name) do
      definition = Taro::Rails.definitions[controller_class][method_name]
      @api_params = definition.parse_params(params)
    end
  end

  def self.installed
    @installed ||= {}
  end
end
