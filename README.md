# ABLab

A minimal library for performing AB-tests and checking their statistical
significance.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ablab'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ablab


## Usage

```ruby
# In `initializers/ablab.rb`

ABLab.setup do
  experiment :product_page do
    description "Experiments on the product page"

    bucket :a, description: "control group"
    bucket :b, description: "show more products from the shop at the top"
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
```


## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/lucaong/ablab).
