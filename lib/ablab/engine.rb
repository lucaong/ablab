require 'rails'

module Ablab
  class Engine < ::Rails::Engine
    isolate_namespace Ablab

    initializer "ablab.assets.precompile" do |app|
      app.config.assets.precompile += %w(tracker.js)
    end
  end
end
