begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Ablab'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

load 'rails/tasks/statistics.rake'

require "rspec/core/rake_task"

Bundler::GemHelper.install_tasks(name: 'ablab')

namespace :core do
  Bundler::GemHelper.install_tasks(name: 'ablab-core')
end

RSpec::Core::RakeTask.new(:spec)
task default: :spec
