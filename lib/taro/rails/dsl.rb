module Taro::Rails::DSL
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
