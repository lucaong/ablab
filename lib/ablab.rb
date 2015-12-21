require "ablab/version"
require "ablab/helper"
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
    attr_reader :name, :groups, :control

    def initialize(name, &block)
      @name    = name.to_sym
      @control = Group.new(:control, 'control group')
      @groups  = [@control]
      instance_exec(&block)
    end

    def description(desc = nil)
      @description = desc if desc
      @description
    end

    def group(name, options = {})
      group = Group.new(name, options[:description])
      @groups << group
    end

    def results
      @result ||= Result.new(self)
      @result.data
    end

    def run(uid)
      draw = Random.new(uid.hash * name.hash).rand(1000)
      Run.new(self, draw)
    end
  end

  class Run
    attr_reader :group, :experiment

    def initialize(experiment, draw)
      idx         = (draw / (1000.0 / experiment.groups.size)).floor
      @experiment = experiment
      @group      = experiment.groups[idx].name
    end

    def in_group?(name)
      group == name
    end

    def track_view!
      ABLab.tracker.track_view!(experiment.name, group)
    end

    def track_conversion!
      ABLab.tracker.track_conversion!(experiment.name, group)
    end
  end

  class Group
    attr_reader :name, :description
    def initialize(name, description = nil)
      @name, @description = name.to_sym, description
    end
  end

  class Result
    extend Forwardable
    def_delegators :@experiment, :name, :control, :groups

    def initialize(experiment)
      @experiment = experiment
    end

    def data
      c_views, c_conv = views_and_conversions(control)
      groups.map do |group|
        if group == control
          next { views: c_views, conversions: c_conv, control: true }
        end
        views, conv = views_and_conversions(group)
        z = z_score(views, conv, c_views, c_conv)
        { views: views, conversions: conv, z_score: z, control: false }
      end
    end

    private def views_and_conversions(group)
      views       = ABLab.tracker.views(name, group.name)
      conversions = ABLab.tracker.conversions(name, group.name)
      [views, conversions]
    end

    private def z_score(views, conv, c_views, c_conv)
      p  = conv.to_f / views
      pc = c_conv.to_f / c_views
      (p - pc) / Math.sqrt((p*(1 - p) / views) + (pc*(1 - pc) / c_views))
    end
  end
end
