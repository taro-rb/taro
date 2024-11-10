module Taro::Rails::DSL
  def api(description)
    Taro::Rails.buffered_declaration(self).api = description
  end

  def param(param_name, **kwargs)
    Taro::Rails.buffered_declaration(self).add_param(param_name, **kwargs)
  end

  def returns(field_name = nil, **kwargs)
    Taro::Rails.buffered_declaration(self).add_return(field_name, **kwargs)
  end

  def method_added(method_name)
    Taro::Rails.apply_buffered_declaration(self, method_name)
    super
  end
end
