ABLab.setup do
  store :redis, host: 'localhost', port: 6379

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

experiment(:product_page).in_bucket?(:a) # => true or false
experiment(:product_page).bucket         # => :a or :b

experiment(:product_page).track_view!
experiment(:product_page).track_conversion!
