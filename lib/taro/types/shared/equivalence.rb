module Taro::Types::Shared::Equivalence
  def equivalent?(other)
    equal?(other) || equal_properties?(other)
  end

  def equal_properties?(other)
    return false unless other.openapi_type == openapi_type

    # @fields is lazy-loaded. Comparing @field_defs suffices.
    ignored = %i[@fields]
    props = instance_variables - ignored
    props == (other.instance_variables - ignored) &&
      props.all? { |p| instance_variable_get(p) == other.instance_variable_get(p) }
  end
end
