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

    def run(session_id)
      Run.new(self, session_id)
    end
  end

  class Run
    attr_reader :experiment, :session_id

    def initialize(experiment, session_id)
      @experiment, @session_id = experiment, session_id
      @experiment = experiment
    end

    def in_group?(name)
      group == name
    end

    def track_view!
      ABLab.tracker.track_view!(experiment.name, group, session_id)
    end

    def track_success!
      ABLab.tracker.track_success!(experiment.name, group, session_id)
    end

    def group
      return @group unless @group.nil?
      idx = (draw / (1000.0 / experiment.groups.size)).floor
      @group = experiment.groups[idx].name
    end

    def draw
      Random.new(session_id.hash * experiment.name.hash).rand(1000)
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
      counts_c = counts(control)
      groups.map do |group|
        if group == control
          next counts_c.merge(control: true)
        end
        counts = counts(group)
        z = z_score(counts[:sessions], counts[:conversions],
                    counts_c[:sessions], counts_c[:conversions])
        counts.merge(z_score: z, control: false)
      end
    end

    private def counts(group)
      ABLab.tracker.counts(name, group.name)
    end

    private def z_score(s, c, sc, cc)
      p  = [c.to_f / s, 1.0].min
      pc = [cc.to_f / sc, 1.0].min
      (p - pc) / Math.sqrt((p*(1 - p) / s) + (pc*(1 - pc) / sc))
    end
  end
end
