$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ablab/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ablab-core"
  s.version     = Ablab::VERSION
  s.authors     = ["Luca Ongaro"]
  s.email       = ["lukeongaro@gmail.com"]
  s.homepage    = "https://github.com/lucaong/ablab"
  s.summary     = "Ablab core - A/B testing library"
  s.description = "Ablab - A/B testing library"
  s.license     = "MIT"

  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"].reject do |f|
    %w(engine.rb helper.rb).include?(File.basename(f))
  end
  s.test_files = Dir["spec/**/*"].reject do |f|
    %w(engine_spec.rb helper_spec.rb).include?(File.basename(f))
  end

  s.add_dependency "redis"

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
end

