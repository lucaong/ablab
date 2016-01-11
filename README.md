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

    # A control group, named `:control`, is automatically generated
    # for each experiment. Create your own groups by calling `group`:
    group :top_ads, description: "show ads at the top of the page"
  end

  experiment :search do
    description "Search experiments"

    group :ctr, description: "boost by CTR"
    group :gmv, description: "boost by GMV"
  end
end


# In application_controller.rb

require 'ablab'

class ApplicationController < ActionController::Base
  include ABLab::Helper
end


# In app controllers/views code

experiment(:product_page).in_group?(:top_ads) # => true or false
experiment(:product_page).group               # => :control or :top_ads

experiment(:product_page).track_view!
experiment(:product_page).track_conversion!


# Results of the experiment
ABTest.experiments.each do |experiment|
  puts "#{experiment.name}: #{experiment.results.inspect}"
end
```


## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/lucaong/ablab).
