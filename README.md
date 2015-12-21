# ABLab

A minimal library for performing AB-tests in Rails applications and checking
their statistical significance.


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
  store :redis, host: 'localhost', port: 6379

  experiment :product_page do
    description "Experiments on the product page"

    group :a, control: true, description: "control group"
    group :b, description: "show more products from the shop at the top"
  end

  experiment :search do
    description "Search experiments"

    group :a, control: true, description: "control group"
    group :b, description: "boost CTR"
    group :c, description: "boost GMV"
  end
end


# In application_controller.rb

require 'ablab'

class ApplicationController < ActionController::Base
  include ABLab::Controller
end


# In app controllers/views code

experiment(:product_page).in_group?(:a) # => true or false
experiment(:product_page).group         # => :a or :b

experiment(:product_page).track_view!
experiment(:product_page).track_conversion!


# Results of the experiment
ABTest.experiments.each do |experiment|
  puts "#{experiment.name}: #{experiment.results.inspect}"
end
```


## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/lucaong/ablab).
