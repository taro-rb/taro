# `type_class` is a convenience method to get the type class of types,
# of with_cache-types, of type instances, and of fields in the same way.
module Taro::Types::Shared::TypeClass
  def self.included(klass)
    if klass.instance_methods.include?(:type) # Field
      klass.alias_method                 :type_class, :type
    else # BaseType
      klass.singleton_class.alias_method :type_class, :itself
      klass.alias_method                 :type_class, :class
    end
  end
end
