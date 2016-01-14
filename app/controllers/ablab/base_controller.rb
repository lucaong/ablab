require_dependency "ablab/application_controller"

module Ablab
  class BaseController < ApplicationController
    if Ablab.dashboard_credentials
      http_basic_authenticate_with Ablab.dashboard_credentials.merge(only: :dashboard)
    end

    def track
      exp = experiment(params[:experiment].to_sym)
      Thread.new do
        if params[:event] == 'success'
          exp.track_success!
        else
          exp.track_view!
        end
      end
      respond_to do |format|
        format.js
      end
    end

    def dashboard
      @experiments = Ablab.experiments
    end
  end
end
