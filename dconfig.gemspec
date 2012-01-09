# -*- encoding: utf-8 -*-
# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |gem|
  gem.name = "dconfig"
  gem.summary = "Dynamic Redis Store"
  gem.description = "Dynamic Configuration stored on redis"
  gem.authors = [%q{maxjgon}]

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  gem.add_dependency 'railties', ['>= 3.0.0']
  gem.add_dependency 'redis', ['~> 2.2.2']
  gem.add_dependency 'redis-namespace', ['~> 1.0.3']

  gem.add_development_dependency "rails", ">= 3.0.0"
  gem.add_development_dependency "sqlite3"


  gem.version = "0.0.1"
end
