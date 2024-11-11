module Taro::Config
  singleton_class.attr_accessor(
    :parse_params,
    :validate_response,
  )

  # defaults
  self.parse_params = true
  self.validate_response = true
end

def Taro.config
  Taro::Config
end
