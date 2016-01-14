[![Build Status](https://travis-ci.org/lucaong/ablab.svg?branch=master)](https://travis-ci.org/lucaong/ablab)
[![Code Climate](https://codeclimate.com/github/lucaong/ablab/badges/gpa.svg)](https://codeclimate.com/github/lucaong/ablab)

# Ablab

A minimal library for performing AB-tests in Rails applications and tracking
their result and statistical significance.


## Installation and Usage

Add this line to your Rails app's `Gemfile` and run bundler:

```ruby
gem 'ablab'
```

In your app's `config/routes.rb`, mount `Ablab::Engine`:

```ruby
# config/routes.rb

mount Ablab::Engine => '/ablab'
```

Include `Ablab::Helper` in your `app/controller/application_controller.rb`:

```ruby
# app/controller/application_controller.rb

class ApplicationController < ActionController::Base
  include Ablab::Helper
end
```

Add the `Ablab` JavaScript in your bundle:

```javascript
// app/assets/javascripts/application.js

//= require ablab/tracker
```

Create an initializer file to setup your experiments:

```ruby
# config/initializers/ablab.rb

Ablab.setup do
  # Use redis to store experiment tracking data
  store :redis, host: 'localhost', port: 6379

  # Protect dashboard under HTTP basic auth
  dashboard_credentials name: 'sterling', password: 'd4ng3rz0ne'

  # Setup experiment
  experiment :add_to_cart_button do
    # Describe the experiment
    description 'Experiments on different versions of the cart button'

    # Describe the goal tracked
    goal 'click on add-to-cart button'

    # A control group, named `:control`, is automatically generated
    # for each experiment. Create your own groups by calling `group`:
    group :version_a, description: 'big green button'
    group :version_b, description: 'smaller button at the top of the page'
  end

  # You can setup as many experiments as you wish
  experiment :search do
    description 'Search experiments'

    # You can restrict the experiment only to a certain percentage of users (the
    # groups will still be equally sized within the given percentage)
    percentage_of_visitors 20

    group :ctr, description: 'boost by CTR'
    group :gmv, description: 'boost by GMV'
  end
end
```

In your controller or view code use the helper to implement the experiments:

```ruby
# In app controllers/views code

# Write your code conditional to the current user's group, in this case
# :control, :version_a or :version_b
case experiment(:add_to_cart_button).group
when :version_a
  # ...render version A
when :version_b
  # ...render version B
else
  # ...control group
end
```

Track views and goals in Ruby:

```ruby
experiment(:add_to_cart_button).track_view!    # to track view
experiment(:add_to_cart_button).track_success! # to track goal
```

...or in JavaScript:

```javascript
Ablab.trackView('add_to_cart_button')    // to track view
Ablab.trackSuccess('add_to_cart_button') // to track goal
```

Then go to `yourapp.com/ablab` to see the experiment dashboard.


## Screenshot

![Ablab Dashboard](https://raw.githubusercontent.com/lucaong/ablab/master/dashboard.png)


## Feature Wishlist

  - Pause/resume experiments
  - See how long an experiment has been running
  - Set in which group you get assigned for testing purposes


## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/lucaong/ablab).
