module Taro::Rails::DSL
  def api(summary, **kwargs)
    Taro::Rails.buffered_declaration(self).add_info(summary, **kwargs)
  end

  def param(param_name, **kwargs)
    kwargs[:defined_at] = caller_locations(1..1)[0]
    Taro::Rails.buffered_declaration(self).add_param(param_name, **kwargs)
  end

  def returns(field_name = nil, **kwargs)
    kwargs[:defined_at] = caller_locations(1..1)[0]
    Taro::Rails.buffered_declaration(self).add_return(field_name, **kwargs)
  end

  def method_added(method_name)
    Taro::Rails.apply_buffered_declaration(self, method_name)
    super
  end

  def common_return(**kwargs)
    kwargs[:defined_at] = caller_locations(1..1)[0]
    Taro::Rails::CommonReturns.define(self, **kwargs)
  end
end
