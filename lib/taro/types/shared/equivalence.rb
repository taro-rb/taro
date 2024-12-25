module Taro::Types::Shared::Equivalence
  def equivalent?(other)
    equal?(other) || equal_properties?(other)
  end

  def equal_properties?(other)
    return false unless other.openapi_type == openapi_type

    # @fields is lazy-loaded. Comparing @field_defs suffices.
    ignored = %i[@fields]
    (instance_variables - ignored).to_h { |i| [i, instance_variable_get(i)] } ==
      (other.instance_variables - ignored).to_h { |i| [i, other.instance_variable_get(i)] }
  end
end
