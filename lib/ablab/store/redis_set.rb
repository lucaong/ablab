require 'redis'

module Ablab
  module Store
    class RedisSet
      attr_reader :redis

      def initialize(opts = {})
        @key_prefix = opts[:key_prefix] || 'ablab'
        @redis = ::Redis.new(opts)
        @session_duration = opts[:session_duration] || (60 * 30)
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
        s, z = nil, nil
        redis.multi do
          s = redis.zcard(key(:sessions, experiment, bucket))
          z = redis.get(key(:'sessions:spool', experiment, bucket))
        end
        (s.value || 0).to_i + (z.value || 0).to_i
      end

      def successes(experiment, bucket)
        (redis.get(key(:successes, experiment, bucket)) || 0).to_i
      end

      def conversions(experiment, bucket)
        c, z = nil, nil
        redis.multi do
          c = redis.zcard(key(:conversions, experiment, bucket))
          z = redis.get(key(:'conversions:spool', experiment, bucket))
        end
        (c.value || 0).to_i + (z.value || 0).to_i
      end

      def counts(experiment, bucket)
        v, s, k, x, c, z = nil, nil, nil, nil, nil, nil
        redis.multi do
          v = redis.get(key(:views, experiment, bucket))
          s = redis.zcard(key(:sessions, experiment, bucket))
          k = redis.get(key(:'sessions:spool', experiment, bucket))
          x = redis.get(key(:successes, experiment, bucket))
          c = redis.zcard(key(:conversions, experiment, bucket))
          z = redis.get(key(:'conversions:spool', experiment, bucket))
        end
        {
          views:       (v.value || 0).to_i,
          sessions:    (s.value || 0).to_i + (k.value || 0).to_i,
          successes:   (x.value || 0).to_i,
          conversions: (c.value || 0).to_i + (z.value || 0).to_i
        }
      end

      private def key(type, experiment, bucket)
        "#{@key_prefix}:#{type}:#{experiment}:#{bucket}"
      end

      private def track(experiment, bucket, session_id, counter, set)
        return false if bucket.nil?
        redis.pipelined do
          redis.incr(key(counter, experiment, bucket))
          redis.zadd(key(set, experiment, bucket), Time.now.to_i, session_id)
        end
        spool_set!(experiment, bucket, set) if rand(100) < 1
      end

      private def spool_set!(experiment, bucket, set)
        n = redis.zremrangebyscore(key(set, experiment, bucket), 0, Time.now.to_i - @session_duration)
        redis.incrby(key("#{set}:spool", experiment, bucket), n)
      end
    end
  end
end

