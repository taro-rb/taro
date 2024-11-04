module Taro::Rails::ControllerExtension
  def self.prepended(base)
    base.extend(ClassMethods)
  end

  def render(*, **render_kwargs, &)
    Taro::Rails::ResponseValidator.new(controller: self, render_kwargs:).call
    super(*, **render_kwargs, &)
  end

  module ClassMethods
    def api(description)
      Taro::Rails.buffered_definition(self).api = description
    end

    def accepts(type)
      Taro::Rails.buffered_definition(self).accepts = type
    end

    def returns(**kwargs)
      Taro::Rails.buffered_definition(self).returns = kwargs
    end

    def method_added(method_name)
      Taro::Rails.apply_buffered_definition(self, method_name)
      super
    end
  end
end
