module Taro::Rails::ControllerExtension
  def self.prepended(base)
    base.extend(Taro::Rails::DSL)
  end

  def render(*, **render_kwargs, &)
    Taro::Rails::ResponseValidator.new(controller: self, render_kwargs:).call
    super(*, **render_kwargs, &)
  end
end
