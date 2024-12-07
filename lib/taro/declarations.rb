module Taro
  def self.declarations
    DeclarationsMap
  end

  module DeclarationsMap
    class << self
      include Enumerable

      def [](key)
        map[key]
      end

      def []=(key, declaration)
        map.key?(key) && raise(Taro::InvariantError, "#{key} already declared")
        map[key] = declaration
      end

      def each(&)
        map.each_value(&)
      end

      def reset
        map.clear
      end

      private

      def map
        @map ||= {}
      end
    end
  end
end
