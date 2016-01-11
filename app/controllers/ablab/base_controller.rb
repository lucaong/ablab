require_dependency "ablab/application_controller"

module Ablab
  class BaseController < ApplicationController
    def track
      exp = experiment(params[:experiment].to_sym)
      if params[:event] == 'success'
        exp.track_success!
      else
        exp.track_view!
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
