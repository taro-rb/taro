module Taro::Rails::ParamParsing
  def self.install(controller_class:, action_name:)
    return unless Taro.config.parse_params

    key = [controller_class, action_name]
    return if installed[key]

    installed[key] = true

    controller_class.before_action(only: action_name) do
      definition = Taro::Rails.definitions[controller_class][action_name]
      @api_params = definition.parse_params(params)
    end
  end

  def self.installed
    @installed ||= {}
  end
end
