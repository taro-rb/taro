module Taro::Rails::CommonReturns
  module InheritedCallback
    def inherited(new_class)
      Taro::Rails::CommonReturns.inherit(self, new_class)
      super
    end
  end

  class << self
    def define(klass, **kwargs)
      klass.extend(InheritedCallback)
      (map[klass] ||= []) << kwargs
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
end
