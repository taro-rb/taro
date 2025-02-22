module Taro::Types::Shared::DerivedTypes
  # Adds `name` as a method to all type classes and adds
  # :`name`_of as a supported key to the Coercion module.
  # When `name` is called on a type class T, it returns a new subclass
  # S inheriting from `type` and passes T to S::derive_from.
  def define_derived_type(name, derivable_type)
    add_coercion_key(name)
    add_derivation_method(name, derivable_type)
  end

  def derived_types
    Taro::Types::Shared::DerivedTypes.map[self] ||= {}
  end

  def self.map
    @map ||= {}
  end

  private

  def add_coercion_key(base_name)
    new_key = :"#{base_name}#{Taro::Types::Coercion.derived_suffix}"
    if Taro::Types::Coercion.keys.include?(new_key)
      raise ArgumentError, "#{new_key} is already in use"
    end

    Taro::Types::Coercion.keys << new_key
  end

  def add_derivation_method(method_name, type)
    root = Taro::Types::BaseType
    if root.respond_to?(method_name)
      raise ArgumentError, "#{method_name} is already in use"
    end

    root.define_singleton_method(method_name) do
      derived_types[type] ||= begin
        name || raise(Taro::ArgumentError, 'Cannot derive from anonymous type')

        type_class = Taro::Types::Coercion.call(type:)
        new_type = Class.new(type_class)
        new_type.define_name("#{name}.#{method_name}")
        new_type.derive_from(self)
        new_type
      end
    end
  end
end
