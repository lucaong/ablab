require "ablab/version"
require "ablab/controller"
require "ablab/store"

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

    def store(type, *args)
      if type.is_a? Class
        @tracker = Class.new(*args)
      else
        class_name = type.to_s.split('_').map(&:capitalize).join
        @tracker = ABLab::Store.const_get(class_name).new(*args)
      end
    end

    def tracker
      @tracker ||= ABLab::Store::Memory.new
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
      ABLab.tracker.track_view!(experiment.name, bucket)
    end

    def track_conversion!
      ABLab.tracker.track_conversion!(experiment.name, bucket)
    end
  end

  class Bucket < Struct.new(:name, :description); end
end
