module Taro::Types::Shared::Caching
  def cached_coerce_response
    Taro::Cache.call(object, cache_key: self.class.cache_key, expires_in: self.class.expires_in) do
      coerce_response
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
    klass.singleton_class.attr_accessor :expires_in, :without_cache
    klass.singleton_class.attr_reader :cache_key
  end

  module ClassMethods
    def cache_key=(arg)
      arg.nil? || arg.is_a?(Proc) && arg.arity == 1 || arg.is_a?(Hash) ||
        raise(Taro::ArgumentError, "Type.cache_key must be a Proc with arity 1, a Hash, or nil")

      @cache_key = arg
    end

    def with_cache(cache_key:, expires_in: nil)
      klass = dup
      klass.cache_key = cache_key.is_a?(Proc) ? cache_key : ->(_) { cache_key }
      klass.expires_in = expires_in
      klass.without_cache = self
      klass
    end
  end
end
