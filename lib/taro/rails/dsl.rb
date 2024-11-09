module Taro::Rails::DSL
  def api(description)
    Taro::Rails.buffered_declaration(self).api = description
  end

  def accepts(type)
    Taro::Rails.buffered_declaration(self).accepts = type
  end

  def returns(**kwargs)
    Taro::Rails.buffered_declaration(self).returns = kwargs
  end

  def method_added(method_name)
    Taro::Rails.apply_buffered_declaration(self, method_name)
    super
  end
end
