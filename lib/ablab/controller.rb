module ABLab
  module Controller
    private def experiment(name)
      @experiments ||= {}
      unless ABLab.experiments.has_key?(name)
        raise "No experiment with name #{name}"
      end
      @experiments[name] ||=
        ABLab.experiments[name].run(user_id_for_experiments)
    end

    private def user_id_for_experiments
      env['rack.session'].id
    end
  end
end
