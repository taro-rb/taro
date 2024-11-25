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
      if [:object, :pattern].include?(name)
        raise(Taro::ArgumentError, "##{name} is a reserved, internally used method name")
      elsif ![:coerce_input, :coerce_response].include?(name) &&
            !self.name.to_s.start_with?('Taro::Types::')
        custom_resolvers[name] = true
      end

      super
    end

    def inherited(subclass)
      subclass.instance_variable_set(:@custom_resolvers, custom_resolvers.dup)
      super
    end
  end
end
