require "ablab/version"
require "ablab/helper"
require "ablab/store"
require "ablab/engine"
require "forwardable"

module Ablab
  module ModuleMethods
    TRACKING_EXCEPTION_HANDLER = Proc.new { |e| raise e }
    ALLOW_TRACKING = Proc.new { true }

    def experiments
      @experiments ||= {}
    end

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
        @tracker = Ablab::Store.const_get(class_name).new(*args)
      end
    end

    def tracker
      @tracker ||= Ablab::Store::Memory.new
    end

    def dashboard_credentials(credentials = nil)
      if credentials
        unless credentials[:name] && credentials[:password]
          raise InvalidCredentials, 'credentials should provide name and password'
        end
        @dashboard_credentials = credentials
      end
      @dashboard_credentials
    end

    def on_track(&block)
      (@callbacks ||= []) << block
    end

    def allow_tracking(&block)
      @allow_tracking = block if block_given?
      @allow_tracking || ALLOW_TRACKING
    end

    def on_tracking_exception(&block)
      @tracking_exception_handler = block
    end

    def tracking_exception_handler
      @tracking_exception_handler || TRACKING_EXCEPTION_HANDLER
    end

    def callbacks
      @callbacks || []
    end
  end

  class InvalidCredentials < ArgumentError; end

  extend ModuleMethods

  class Experiment
    attr_reader :name, :groups, :control, :callbacks

    def initialize(name, &block)
      @name      = name.to_sym
      @control   = Group.new(:control, 'control group')
      @groups    = [@control]
      @callbacks = []
      instance_exec(&block)
    end

    def description(desc = nil)
      @description = desc if desc
      @description
    end

    def goal(goal = nil)
      @goal = goal if goal
      @goal
    end

    def percentage_of_visitors(percentage = nil)
      @percentage_of_visitors = percentage if percentage
      @percentage_of_visitors || 100
    end

    def group(name, options = {})
      group = Group.new(name, options[:description])
      @groups << group
    end

    def on_track(&block)
      @callbacks << block
    end

    def results
      @result ||= Result.new(self)
      @result.data
    end

    def run(session_id, request)
      Run.new(self, session_id, request)
    end
  end

  class Run
    attr_reader :experiment, :session_id, :request

    def initialize(experiment, session_id, request)
      @experiment, @session_id, @request = experiment, session_id, request
    end

    def in_group?(name)
      group == name
    end

    def track_view!
      track!(:view)
    end

    def track_success!
      track!(:success)
    end

    def group
      return @group unless @group.nil?
      forced = forced_group
      return forced if forced
      size = 1000.0 * (experiment.percentage_of_visitors) / 100.0
      idx = (draw * experiment.groups.size / size).floor
      @group = experiment.groups[idx].try(:name)
    end

    def draw
      sid_hash = Digest::SHA1.hexdigest(session_id)[-8..-1].to_i(16)
      exp_hash = Digest::SHA1.hexdigest(experiment.name.to_s)[-8..-1].to_i(16)
      (sid_hash ^ exp_hash) % 1000
    end

    def perform_callbacks!(event)
      experiment.callbacks.each do |cbk|
        cbk.call(event, experiment.name, group, session_id, request)
      end
      Ablab.callbacks.each do |cbk|
        cbk.call(event, experiment.name, group, session_id, request)
      end
    rescue => e
      Ablab.tracking_exception_handler.call(e)
    end

    private def forced_group
      return nil unless request && request.respond_to?(:params)
      groups = parse_groups(request.params[:ablab_group])
      group  = groups[experiment.name.to_s]
      group.to_sym if group && experiment.groups.map { |g| g.name.to_s }.include?(group)
    end

    private def parse_groups(str)
      return {} unless str
      hash = str.split(/\s*,\s*/).map do |s|
        exp_group = s.split(/\s*:\s*/).take(2)
        exp_group if exp_group.size == 2
      end.compact.to_h
    end

    private def track!(event)
      if allowed?(experiment.name, group, session_id, request)
        method = (event == :view) ? :track_view! : :track_success!
        Ablab.tracker.send(method, experiment.name, group, session_id)
        Thread.new do
          perform_callbacks!(event)
        end
      end
    rescue => e
      Ablab.tracking_exception_handler.call(e)
    end

    private def allowed?(experiment_name, group, session_id, request)
      filter = Ablab.allow_tracking
      filter.call(experiment_name, group, session_id, request)
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
          next [group.name, counts_c.merge(control: true, description: group.description)]
        end
        counts = counts(group)
        z = z_score(counts[:sessions], counts[:conversions],
                    counts_c[:sessions], counts_c[:conversions])
        [group.name, counts.merge(z_score: z, control: false, description: group.description)]
      end.to_h
    end

    private def counts(group)
      Ablab.tracker.counts(name, group.name)
    end

    private def z_score(s, c, sc, cc)
      return nil if s == 0 || sc == 0
      p  = c.to_f / s
      pc = cc.to_f / sc
      (p - pc) / Math.sqrt((p*(1 - p) / s) + (pc*(1 - pc) / sc))
    end
  end
end
