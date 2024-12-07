require_relative 'response_type'

# @api private - this type is only for internal use in Declarations.
class Taro::Types::NestedResponseType < Taro::Types::ResponseType
  def self.nesting_field
    fields.size == 1 || raise(
      Taro::InvariantError, "#{self} should have 1 field, got #{fields}"
    )
    fields.each_value.first
  end

  def self.default_openapi_name
    field = nesting_field
    "#{field.type.openapi_name}_in_#{field.name}_Response"
  end
end
