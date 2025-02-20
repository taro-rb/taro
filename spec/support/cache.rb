DUMMY_CACHE = Object.new
DUMMY_CACHE.define_singleton_method(:fetch) { |*, &block| block.call }
Taro::Cache.cache_instance = DUMMY_CACHE
