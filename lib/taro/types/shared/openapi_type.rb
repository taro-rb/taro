# Provides a setter and getter for type classes' `openapi_type`,
# for use in the OpenAPI export.
module Taro::Types::Shared::OpenAPIType
  OPENAPI_TYPES = %i[
    array
    boolean
    integer
    number
    object
    string
  ].freeze

  def openapi_type
    @openapi_type || raise(Taro::RuntimeError, "Type lacks openapi_type: #{self}")
  end

  def openapi_type=(arg)
    OPENAPI_TYPES.include?(arg) ||
      raise(Taro::ArgumentError, "openapi_type must be a Symbol, one of #{OPENAPI_TYPES}")
    @openapi_type = arg
  end

  def inherited(subclass)
    subclass.instance_variable_set(:@openapi_type, @openapi_type)
    super
  end
end
