# Lazily-evaluated response type definition.
class Taro::ReturnDef
  attr_reader :code, :defined_at, :desc, :nesting, :params

  def initialize(code:, defined_at: nil, desc: nil, nesting: nil, **params)
    @code = Taro::StatusCode.coerce_to_int(code)
    @defined_at = defined_at
    @desc = desc
    @nesting = nesting
    @params = params
    validate
  end

  def evaluate
    if nesting
      Class.new(Taro::Types::NestedResponseType).tap do |type|
        type.field(nesting, defined_at:, null: false, **params)
      end
    else
      Taro::Types::Coercion.call(params)
    end
  end

  private

  def validate
    # For nested returns, call ::field, which validates
    # field options, but does not trigger type auto-loading.
    return evaluate if nesting

    if params.key?(:null)
      raise Taro::ArgumentError, <<~MSG
        `null:` is not supported for top-level returns. If you want a nullable return
        value, nest it, e.g. `returns :str, type: 'String', null: true`.
      MSG
    end

    bad_keys = params.keys - (Taro::Types::Coercion.keys + %i[defined_at])
    return if bad_keys.empty?

    raise Taro::ArgumentError, "Invalid `returns` options: #{bad_keys.join(', ')}"
  end
end
