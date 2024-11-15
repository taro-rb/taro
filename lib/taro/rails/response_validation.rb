module Taro::Rails::ResponseValidation
  def self.install(controller_class:, action_name:)
    return unless Taro.config.validate_response

    key = [controller_class, action_name]
    return if installed[key]

    installed[key] = true

    controller_class.around_action(only: action_name) do |_, block|
      Taro::Types::BaseType.rendering = nil
      block.call
      Taro::Rails::ResponseValidation.call(self)
    ensure
      Taro::Types::BaseType.rendering = nil
    end
  end

  def self.installed
    @installed ||= {}
  end

  def self.call(controller)
    declaration = Taro::Rails.declaration_for(controller)
    nesting = declaration.return_nestings[controller.status]
    expected = declaration.returns[controller.status]
    if nesting
      # case: `returns :some_nesting, type: 'SomeType'` (ad-hoc return type)
      check_nesting(controller.response, nesting)
      expected = expected.fields[nesting].type
    end

    check_expected_type_was_used(controller, expected)
  end

  def self.check_nesting(response, nesting)
    return unless /json/.match?(response.media_type)

    first_key = response.body.to_s[/\A{\s*"([^"]+)"/, 1]
    first_key == nesting.to_s || raise(Taro::ResponseError, <<~MSG)
      Expected response to be nested in "#{nesting}" key, but it was not.
      (First JSON key in response: "#{first_key}".)
    MSG
  end

  def self.check_expected_type_was_used(controller, expected)
    used = Taro::Types::BaseType.rendering

    if expected.nil?
      raise(Taro::ResponseError, <<~MSG)
        No matching return type declared in #{controller.class}##{controller.action_name}\
        for status #{controller.status}.
      MSG
    end

    used&.<=(expected) || raise(Taro::ResponseError, <<~MSG)
      Expected #{controller.class}##{controller.action_name} to use #{expected}.render,
      but #{used ? "#{used}.render" : 'no type render method'} was called.
    MSG

    Taro::Types::BaseType.used_in_response = used # for comparisons in specs
  end
end
