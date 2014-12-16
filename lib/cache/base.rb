module Cache
  class Base

    def fetch(*keys)
      # Build key - cache_key map
      cache_key_map = Hash[keys.map{ |key| [key, transform_cache_key(key)] }]

      # Load objects from cache
      cache_results = cache_store.read_multi(*cache_key_map.values, cache_store_call_options)

      # Build result hash
      result = cache_key_map.each_with_object Hash.new do |(key, cache_key), r|
        r[key] = transform_value_object cache_results[cache_key]
      end

      # Load missed objects and cache them in store
      unless (missed_keys = keys.reject{ |key| cache_results.key? cache_key_map[key] }).empty?
        missed_objects = load_objects(missed_keys)

        missed_keys.zip(missed_objects).each do |key, obj|
          update key, obj
          result[key] = obj
        end
      end

      result
    end

    def update(key, object = nil)
      cache_store.write(transform_cache_key(key), transform_cache_object(object || load_objects([key]).first), cache_store_call_options)
    end

    def invalidate(key)
      cache_store.delete(transform_cache_key(key), cache_store_call_options)
    end

    private

    def load_objects(keys)
      raise StandardError, "Object loading not implemented"
    end

    def transform_cache_key(key)
      key
    end

    def transform_cache_object(obj)
      obj
    end

    def transform_value_object(obj)
      obj
    end

    def cache_store
      raise StandardError, "Cache store not set"
    end

    def cache_store_call_options
      {}
    end

  end
end