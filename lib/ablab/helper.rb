module ABLab
  module Helper
    def self.included(klass)
      if klass.respond_to? :helper_method
        self.instance_methods(false).each do |method|
          klass.send(:helper_method, method)
          klass.send(:private, method)
        end
      end
    end

    def experiment(name)
      @experiments ||= {}
      unless ABLab.experiments.has_key?(name)
        raise "No experiment with name #{name}"
      end
      @experiments[name] ||=
        ABLab.experiments[name].run(session_id_for_experiments)
    end

    def session_id_for_experiments
      env['rack.session'].id
    end
  end
end
