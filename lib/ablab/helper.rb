require 'securerandom'

module Ablab
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
      unless Ablab.experiments.has_key?(name)
        raise "No experiment with name #{name}"
      end
      @experiments[name] ||=
        Ablab.experiments[name].run(ablab_session_id, request)
    end

    def ablab_session_id
      cookies[:ablab_sid] || cookies[:ablab_sid] = SecureRandom.hex
    end
  end
end
