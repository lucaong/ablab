require 'test_helper'

module Ablab
  class AblabControllerTest < ActionController::TestCase
    setup do
      @routes = Engine.routes
    end

    test "should get track" do
      get :track
      assert_response :success
    end

    test "should get dashboard" do
      get :dashboard
      assert_response :success
    end

  end
end
