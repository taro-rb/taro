module Taro::Types::Shared::DerivedTypes
  def derived_types
    @derived_types ||= {}
  end

  def define_derived_type(name)
    type = self
    root = Taro::Types::BaseType
    raise ArgumentError, "#{name} is already in use" if root.respond_to?(name)

    key = :"#{name}_of"
    keys = Taro::Types::Coercion.keys
    raise ArgumentError, "#{key} is already in use" if keys.include?(key)

    root.define_singleton_method(name) do
      derived_types[type] ||= Class.new(type).tap { |t| t.derive_from(self) }
    end

    keys << key
  end
end
