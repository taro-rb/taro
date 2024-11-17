module Taro::Types::Shared::DerivedTypes
  # Adds `name` as a method to all type classes and adds
  # `name`_of as a supported key to the Coercion module.
  # When `name` is called on a type class T, it returns a new subclass
  # S inheriting from `type` and passes T to S::derive_from.
  def define_derived_type(name, type)
    root = Taro::Types::BaseType
    raise ArgumentError, "#{name} is already in use" if root.respond_to?(name)

    ckey = :"#{name}#{Taro::Types::Coercion.derived_suffix}"
    ckeys = Taro::Types::Coercion.keys
    raise ArgumentError, "#{ckey} is already in use" if ckeys.include?(ckey)

    root.define_singleton_method(name) do
      derived_types[type] ||= begin
        type_class = Taro::Types::Coercion.call(type:)
        Class.new(type_class).tap { |t| t.derive_from(self) }
      end
    end

    ckeys << ckey
  end

  def derived_types
    @derived_types ||= {}
  end
end
