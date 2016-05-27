$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ablab/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ablab"
  s.version     = Ablab::VERSION
  s.authors     = ["Luca Ongaro"]
  s.email       = ["lukeongaro@gmail.com"]
  s.homepage    = "https://github.com/lucaong/ablab"
  s.summary     = "Ablab - A/B testing on Rails"
  s.description = "Ablab - A/B testing on Rails"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails"
  s.add_dependency "redis"

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
end
