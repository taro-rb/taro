# Allows implementing methods on types to override or implement the method
# used to retrieve the value of a field.
module Taro::Types::Shared::CustomFieldResolvers
  def resolve?(method)
    self.class.custom_resolvers.key?(method)
  end

  def self.included(mod)
    mod.extend(ClassMethods)
  end

  module ClassMethods
    def custom_resolvers
      @custom_resolvers ||= {}
    end

    def method_added(name)
      custom_resolvers[name] = true
      super
    end

    def inherited(subclass)
      subclass.instance_variable_set(:@custom_resolvers, custom_resolvers.dup)
      super
    end
  end
end
