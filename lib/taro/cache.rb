module Taro::Cache
  singleton_class.attr_accessor :cache_instance

  def self.call(object, cache_key: nil, expires_in: nil)
    case cache_key
    when nil
      yield
    when Hash, Proc
      call(object, cache_key: cache_key[object], expires_in: expires_in) { yield }
    else
      cache_instance.fetch(cache_key, expires_in: expires_in) { yield }
    end
  end
end
