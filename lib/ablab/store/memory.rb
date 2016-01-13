require 'set'

module Ablab
  module Store
    class Memory
      def initialize
        @views = Hash.new do |hash, key|
          hash[key] = Hash.new { |hash, key| hash[key] = 0 }
        end
        @sessions = Hash.new do |hash, key|
          hash[key] = Hash.new { |hash, key| hash[key] = Set.new }
        end
        @successes = Hash.new do |hash, key|
          hash[key] = Hash.new { |hash, key| hash[key] = 0 }
        end
        @conversions = Hash.new do |hash, key|
          hash[key] = Hash.new { |hash, key| hash[key] = Set.new }
        end
      end

      def track_view!(experiment, bucket, session_id)
        return false if bucket.nil?
        @views[experiment][bucket] += 1
        @sessions[experiment][bucket].add(session_id)
      end

      def track_success!(experiment, bucket, session_id)
        return false if bucket.nil?
        @successes[experiment][bucket] += 1
        @conversions[experiment][bucket].add(session_id)
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
    end
  end
end
