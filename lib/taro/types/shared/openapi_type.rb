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
    @openapi_type
  end

  def openapi_type=(arg)
    OPENAPI_TYPES.include?(arg) ||
      raise(Taro::ArgumentError, "openapi_type must be a Symbol, one of #{OPENAPI_TYPES}")
    @openapi_type = arg
  end
end
