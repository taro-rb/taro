module Taro::Rails::DSL
  def api(summary, **)
    Taro::Rails.buffered_declaration(self).add_info(summary, **)
  end

  def param(param_name, **)
    defined_at = caller_locations(1..1)[0]
    Taro::Rails.buffered_declaration(self).add_param(param_name, defined_at:, **)
  end

  def returns(nesting = nil, **)
    defined_at = caller_locations(1..1)[0]
    Taro::Rails.buffered_declaration(self).add_return(nesting, defined_at:, **)
  end

  def method_added(method_name)
    Taro::Rails.apply_buffered_declaration(self, method_name)
    super
  end

  def common_return(nesting = nil, **)
    defined_at = caller_locations(1..1)[0]
    Taro::CommonReturns.define(self, nesting, defined_at:, **)
  end
end
