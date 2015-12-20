require 'redis'

module ABLab
  module Store
    class Redis
      attr_reader :redis

      def initialize(opts = {})
        @key_prefix = opts[:key_prefix] || 'ablab'
        @redis = ::Redis.new(opts)
      end

      def track_view!(experiment, bucket)
        redis.hincrby(key(:views), field(experiment, bucket), 1)
      end

      def track_conversion!(experiment, bucket)
        redis.hincrby(key(:conversions), field(experiment, bucket), 1)
      end

      def views(experiment, bucket)
        (redis.hget(key(:views), field(experiment, bucket)) || 0).to_i
      end

      def conversions(experiment, bucket)
        (redis.hget(key(:conversions), field(experiment, bucket)) || 0).to_i
      end

      private def key(type)
        "#{@key_prefix}:#{type}"
      end

      private def field(experiment, bucket)
        "#{experiment}:#{bucket}"
      end
    end
  end
end

