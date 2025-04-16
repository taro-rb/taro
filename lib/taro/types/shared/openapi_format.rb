# Provides a setter and getter for type classes' `openapi_format`,
# for use in the OpenAPI export.
module Taro::Types::Shared::OpenAPIFormat
  OPENAPI_STRING_FORMATS = %i[
    date
    date-time
    password
    byte
    binary
    email
    uuid
    uri
    hostname
    ipv4
    ipv6
  ].freeze

  OPENAPI_INTEGER_FORMATS = %i[
    int32
    int64
  ].freeze

  OPENAPI_NUMBER_FORMATS = %i[
    float
    double
  ].freeze

  def openapi_format
    return unless @openapi_format

    unless valid_formats_for_openapi_type.include?(@openapi_format)
      raise(Taro::ArgumentError, "openapi_format #{@openapi_format.inspect} is invalid for openapi_type #{@openapi_type.inspect}, must be one for #{valid_formats_for_openapi_type}")
    end

    @openapi_format
  end

  def openapi_format=(arg)
    @openapi_format = arg
  end

  def inherited(subclass)
    subclass.instance_variable_set(:@openapi_format, @openapi_format)
    super
  end

  private

  def valid_formats_for_openapi_type
    case @openapi_type
    when :string
      OPENAPI_STRING_FORMATS
    when :integer
      OPENAPI_INTEGER_FORMATS
    when :number
      OPENAPI_NUMBER_FORMATS
    else
      []
    end
  end
end
