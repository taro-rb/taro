# Adds the `::field` method to object and input types.
module Taro::Types::Shared::Fields
  # Field types are set using class name Strings. The respective type classes
  # are evaluated lazily to allow for circular or recursive type references,
  # and to avoid unnecessary autoloading of all types in dev/test envs.
  def field(name, **attributes)
    attributes[:defined_at] ||= caller_locations(1..1)[0]
    field_def = Taro::Types::FieldDef.new(name:, **attributes)

    (prev = field_defs[name]) && raise(Taro::ArgumentError, <<~MSG)
      field #{name} at #{field_def.defined_at}
      previously defined at #{prev.defined_at}.
    MSG

    field_defs[name] = field_def
  end

  def fields
    @fields ||= field_defs.transform_values(&:evaluate)
  end

  private

  def field_defs
    @field_defs ||= {}
  end

  def inherited(subclass)
    subclass.instance_variable_set(:@field_defs, field_defs.dup)
    super
  end
end
