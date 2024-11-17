# Provides a setter, getter and defaults for type classes' `openapi_name`,
# for use in the OpenAPI export ($refs and corresponding component names).
module Taro::Types::Shared::OpenAPIName
  def openapi_name
    @openapi_name ||= default_openapi_name
  end

  def openapi_name?
    !!openapi_name
  rescue Taro::Error
    false
  end

  def openapi_name=(arg)
    arg.nil? || arg.is_a?(String) ||
      raise(Taro::ArgumentError, 'openapi_name must be a String')
    @openapi_name = arg
  end

  def default_openapi_name
    if self < Taro::Types::EnumType ||
       self < Taro::Types::InputType ||
       self < Taro::Types::ObjectType
      name && name.chomp('Type').gsub('::', '_') ||
        raise(Taro::Error, 'openapi_name must be set for anonymous type classes')
    elsif self < Taro::Types::ScalarType
      openapi_type
    else
      raise Taro::Error, 'no default_openapi_name implemented for this type'
    end
  end
end
