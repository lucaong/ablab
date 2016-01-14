require 'redis'

module Ablab
  module Store
    class Redis
      attr_reader :redis

      def initialize(opts = {})
        @key_prefix = opts[:key_prefix] || 'ablab'
        @redis = ::Redis.new(opts)
      end

      def track_view!(experiment, bucket, session_id)
        track(experiment, bucket, session_id, :views, :sessions)
      end

      def track_success!(experiment, bucket, session_id)
        track(experiment, bucket, session_id, :successes, :conversions)
      end

      def views(experiment, bucket)
        (redis.get(key(:views, experiment, bucket)) || 0).to_i
      end

      def sessions(experiment, bucket)
        (redis.pfcount(key(:sessions, experiment, bucket)) || 0).to_i
      end

      def successes(experiment, bucket)
        (redis.get(key(:successes, experiment, bucket)) || 0).to_i
      end

      def conversions(experiment, bucket)
        (redis.pfcount(key(:conversions, experiment, bucket)) || 0).to_i
      end

      def counts(experiment, bucket)
        v, s, x, c = nil, nil, nil, nil
        redis.multi do
          v = redis.get(key(:views, experiment, bucket))
          s = redis.pfcount(key(:sessions, experiment, bucket))
          x = redis.get(key(:successes, experiment, bucket))
          c = redis.pfcount(key(:conversions, experiment, bucket))
        end
        {
          views:       (v.value || 0).to_i,
          sessions:    (s.value || 0).to_i,
          successes:   (x.value || 0).to_i,
          conversions: (c.value || 0).to_i
        }
      end

      private def key(type, experiment, bucket)
        "#{@key_prefix}:#{type}:#{experiment}:#{bucket}"
      end

      private def track(experiment, bucket, session_id, counter, unique)
        return false if bucket.nil?
        redis.pipelined do
          redis.incr(key(counter, experiment, bucket))
          redis.pfadd(key(unique, experiment, bucket), session_id)
        end
      end
    end
  end
end

