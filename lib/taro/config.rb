module Taro::Config
  singleton_class.attr_accessor(
    :api_name,
    :api_version,
    :export_format,
    :export_path,
    :parse_params,
    :validate_response,
  )

  # defaults
  self.api_name = 'Taro-based API'
  self.api_version = '1.0'
  self.export_format = :yaml
  self.export_path = 'api.yml'
  self.parse_params = true
  self.validate_response = true
end

def Taro.config
  Taro::Config
end
