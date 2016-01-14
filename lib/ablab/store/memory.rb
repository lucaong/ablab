require 'set'

module Ablab
  module Store
    class Memory
      def initialize
        @views = Hash.new do |hash, key|
          hash[key] = Hash.new { |h, k| h[k] = 0 }
        end
        @sessions = Hash.new do |hash, key|
          hash[key] = Hash.new { |h, k| h[k] = Set.new }
        end
        @successes = Hash.new do |hash, key|
          hash[key] = Hash.new { |h, k| h[k] = 0 }
        end
        @conversions = Hash.new do |hash, key|
          hash[key] = Hash.new { |h, k| h[k] = Set.new }
        end
      end

      def track_view!(experiment, bucket, session_id)
        track(experiment, bucket, session_id, @views, @sessions)
      end

      def track_success!(experiment, bucket, session_id)
        track(experiment, bucket, session_id, @successes, @conversions)
      end

      def views(experiment, bucket)
        @views[experiment][bucket]
      end

      def sessions(experiment, bucket)
        @sessions[experiment][bucket].size
      end

      def successes(experiment, bucket)
        @successes[experiment][bucket]
      end

      def conversions(experiment, bucket)
        @conversions[experiment][bucket].size
      end

      def counts(experiment, bucket)
        {
          views:       views(experiment, bucket),
          sessions:    sessions(experiment, bucket),
          successes:   successes(experiment, bucket),
          conversions: conversions(experiment, bucket)
        }
      end

      private def track(experiment, bucket, session_id, counter, set)
        return false if bucket.nil?
        counter[experiment][bucket] += 1
        set[experiment][bucket].add(session_id)
      end
    end
  end
end
