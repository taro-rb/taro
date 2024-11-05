# Adds the `::field` method to object and input types.
module Taro::Types::Shared::Fields
  # Fields are defined using blocks. These blocks are evaluated lazily
  # to allow for circular or recursive type references, and to
  # avoid unnecessary eager loading of all types in dev/test envs.
  def field(name, &block)
    name.is_a?(Symbol) || raise(Taro::ArgumentError, 'field name must be a Symbol')
    block || raise(Taro::ArgumentError, 'field block is required')

    prev = field_defs[name]
    prev && raise(Taro::ArgumentError, "field #{name} already defined at #{prev[:defined_at]}")

    defined_at = caller_locations(1..1)[0].then { "#{_1.path}:#{_1.lineno}" }
    field_defs[name] = { defined_at:, block: }
  end

  def fields
    @fields ||= evaluate_field_defs
  end

  private

  def field_defs
    @field_defs ||= {}
  end

  def evaluate_field_defs
    field_defs.to_h do |name, definition|
      defined_at, block = definition.values_at(:defined_at, :block)
      type, opts = instance_exec(&block)
      validate_block_result(type, opts, name, defined_at)
      field = Taro::Types::Field.new(**opts.to_h, type:, name:, defined_at:)
      [name, field]
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
