module Taro::Rails::ControllerExtension
  def self.prepended(base)
    base.extend(Taro::Rails::DSL)
  end
end
