module Taro::Config
  singleton_class.attr_accessor(
    :parse_params,
  )

  # defaults
  self.parse_params = true
end

def Taro.config
  Taro::Config
end
