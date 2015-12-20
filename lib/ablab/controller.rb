module ABLab
  module Controller
    private def ab_test(name)
      @ab_tests ||= {}
      @ab_tests[name] ||=
        ABLab.experiments[name].run(user_id_for_ab_test)
    end

    private def user_id_for_ab_test
      env['rack.session'].id
    end
  end
end
