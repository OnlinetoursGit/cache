require 'digest/md5'
require 'hashie/mash'

module Cache
  module Exts
    module Fields

      private

      def fields
        @fields ||= self.class.const_get(:FIELDS)
      end

      def fields_hash
        @fields_hash ||= Digest::MD5.hexdigest fields.join('|')
      end

      def transform_cache_key(key)
        super([*key, fields_hash])
      end

      def transform_cache_object(obj)
        res = fields.each_with_object Hash.new do |key, hash|
          hash[key] = obj.send(key)
        end

        super res
      end

      def transform_value_object(*)
        ::Hashie::Mash.new(super) do |_, key|
          raise NoMethodError, "undefined method '#{key}' for cached data"
        end.tap do |h|
          class << h
            def blank?; false; end unless respond_to? :blank?
            def present?; true; end unless respond_to? :present?
          end
        end
      end
    end
  end
end
