module Taro::Rails::ResponseValidation
  def self.install(controller_class:, action_name:)
    return unless Taro.config.validate_response

    key = [controller_class, action_name]
    return if installed[key]

    installed[key] = true

    controller_class.after_action(only: action_name) do
      Taro::Rails::ResponseValidation.call(self)
    end
  end

  def self.installed
    @installed ||= {}
  end

  def self.call(controller)
    declaration = Taro::Rails.declarations[controller.class][controller.action_name.to_sym]
    expected = declaration.returns[controller.status]
    used = Taro::Types::BaseType.rendered

    used&.<=(expected) || raise(Taro::ResponseError, <<~MSG)
      Expected #{controller.class}##{controller.action_name} to use #{expected}.render,
      but #{used ? "#{used}.render" : 'no type render method'} was called.
    MSG
  end
end
