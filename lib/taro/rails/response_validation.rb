module Taro::Rails::ResponseValidation
  def self.install(controller_class:)
    controller_class.prepend(self) if Taro.config.validate_response
  end

  def render(*, **kwargs, &)
    result = super
    if (declaration = Taro::Rails.declaration_for(self))
      Taro::Rails::ResponseValidator.call(self, declaration, kwargs[:json])
    end
    result
  end
end
