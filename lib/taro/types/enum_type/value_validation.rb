class Taro::Types::EnumType < Taro::Types::BaseType
  module ValueValidation
    attr_reader :value_type

    def validate_value(value)
      type = Taro::Types::CoerceToType.call(value.class)
      @value_type ||= type
      @value_type == type || raise_mixed_value_types(value, type)
      @openapi_type = type.openapi_type ||
                      raise(Taro::ArgumentError, "Type lacks openapi_type: #{type}")

      value
    end

    def raise_mixed_value_types(value, type)
      raise Taro::ArgumentError, <<~MSG
        All values must be of the same type. Mixed enums are not supported for now.
        Expected another #{@value_type} but got #{type} for value #{value.inspect}.
      MSG
    end
  end
end
