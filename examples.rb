ABLab.setup do
  experiment :product_page do
    description "Experiments on the product page"

    bucket :a, description: "control group"
    bucket :b, description: "more products from this shop"
  end

  experiment :search do
    description "Search experiments"

    bucket :a, description: "control group"
    bucket :b, description: "boost CTR"
    bucket :c, description: "boost GMV"
  end
end


# In application_controller.rb

require 'ablab'

class ApplicationController < ActionController::Base
  include ABLab::Controller
end


# In app controllers/views code

ab_test(:product_page).in_bucket?(:a) # true/false
ab_test(:product_page).bucket         # => :a/:b

ab_test(:product_page).track_view!
ab_test(:product_page).track_goal!
