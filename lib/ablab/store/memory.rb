module ABLab
  module Store
    class Memory
      def initialize
        @views = Hash.new do |hash, key|
          hash[key] = Hash.new { |hash, key| hash[key] = 0 }
        end
        @conversions = Hash.new do |hash, key|
          hash[key] = Hash.new { |hash, key| hash[key] = 0 }
        end
      end

      def track_view!(experiment, bucket)
        @views[experiment][bucket] += 1
      end

      def track_conversion!(experiment, bucket)
        @conversions[experiment][bucket] += 1
      end

      def views(experiment, bucket)
        @views[experiment][bucket]
      end

      def conversions(experiment, bucket)
        @conversions[experiment][bucket]
      end
    end
  end
end
