module Taro
  def self.declarations
    DeclarationsMap
  end

  module DeclarationsMap
    class << self
      include Enumerable

      def [](key)
        data[key]
      end

      def []=(key, declaration)
        data.key?(key) && raise(Taro::InvariantError, "#{key} already declared")
        data[key] = declaration
      end

      def each(&)
        data.each_value(&)
      end

      def reset
        data.clear
      end

      def eager_load
        ::Rails.application.eager_load! if defined?(::Rails.application.eager_load!)
        self
      end

      private

      def data
        @data ||= {}
      end
    end
  end
end
