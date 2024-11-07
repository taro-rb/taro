# Adds the `::field` method to object and input types.
module Taro::Types::Shared::Fields
  # Fields are defined using blocks. These blocks are evaluated lazily
  # to allow for circular or recursive type references, and to
  # avoid unnecessary eager loading of all types in dev/test envs.
  def field(name, **kwargs)
    defined_at = caller_locations(1..1)[0].then { "#{_1.path}:#{_1.lineno}" }
    name.is_a?(Symbol) || raise(Taro::ArgumentError, "field name must be a Symbol, got #{name.inspect} at #{defined_at}")

    kwargs.key?(:null) || raise(Taro::ArgumentError, "null has to be specified for field #{name} at #{defined_at}")

    kwargs.values_at(:type, :array_of, :page_of).compact.map(&:class) == [String] ||
      raise(Taro::ArgumentError, "type, array_of, and page_of must be a String for field #{name} at #{defined_at}")

    prev = field_defs[name]
    prev && raise(Taro::ArgumentError, "field #{name} already defined at #{prev[:defined_at]}")

    field_defs[name] = { name:, defined_at:, **kwargs }
  end

  def fields
    @fields ||= evaluate_field_defs
  end

  private

  def field_defs
    @field_defs ||= {}
  end

  def evaluate_field_defs
    field_defs.transform_values do |field_def|
      type = if field_def[:array_of]
        inner_type = Object.const_get(field_def.delete(:array_of))
        Taro::Types::CoerceToType.call(inner_type).list
      elsif field_def[:page_of]
        inner_type = Object.const_get(field_def.delete(:page_of))
        Taro::Types::CoerceToType.call(inner_type).page
      else
        Object.const_get(field_def[:type])
      end
      Taro::Types::Field.new(**field_def, type:)
    end
  end

  def validate_block_result(type, opts, name, defined_at)
    return if type && opts.to_h.key?(:null)

    raise Taro::ArgumentError, <<~MSG
      field block must return a Type and a Hash with :null key, but returned
      #{type}, #{opts} for field #{name} defined at #{defined_at}.
    MSG
  end

  def inherited(subclass)
    subclass.instance_variable_set(:@field_defs, field_defs.dup)
    super
  end
end
