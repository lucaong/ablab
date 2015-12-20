require "ablab/version"
require "ablab/controller"

module ABLab
  module ModuleMethods
    attr_reader :experiments

    def setup(&block)
      instance_exec(&block)
    end

    def experiment(name, &block)
      @experiments ||= {}
      @experiments[name] = Experiment.new(name, &block)
    end
  end

  extend ModuleMethods

  class Experiment
    attr_reader :name, :buckets

    def initialize(name, &block)
      @name    = name
      @buckets = []
      instance_exec(&block)
    end

    def description(desc = nil)
      @description = desc if desc
      @description
    end

    def bucket(name, options = {})
      @buckets << Bucket.new(name, description)
    end

    def run(uid)
      draw = Random.new(uid.hash * name.hash).rand(1000)
      Run.new(self, draw)
    end
  end

  class Run
    attr_reader :bucket, :experiment

    def initialize(experiment, draw)
      idx         = (draw / (1000.0 / experiment.buckets.size)).floor
      @experiment = experiment
      @bucket     = experiment.buckets[idx].name
    end

    def in_bucket?(name)
      bucket == name
    end

    def track_view!
      ABLab.track_view!(experiment.name, bucket)
    end

    def track_goal!
      ABLab.track_goal!(experiment.name, bucket)
    end
  end

  class Bucket < Struct.new(:name, :description); end
end
