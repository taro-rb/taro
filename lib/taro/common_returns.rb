# Holds common return definitions for a set of declarations,
# e.g. shared error responses, within a class and its subclasses.
module Taro::CommonReturns
  class << self
    def define(klass, nesting = nil, **)
      (map[klass] ||= []) << Taro::ReturnDef.new(nesting:, **)
      klass.extend(InheritedCallback)
    end

    def inherit(from_class, to_class)
      map[to_class] = map[from_class].dup
    end

    def for(klass)
      map[klass] || []
    end

    private

    def map
      @map ||= {}
    end
  end

  module InheritedCallback
    def inherited(new_class)
      Taro::CommonReturns.inherit(self, new_class)
      super
    end
  end
end
