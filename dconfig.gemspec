# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dconfig/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = "dconfig"
  gem.summary = "Dynamic Settings"
  gem.description = "Dynamic configuration settings stored on redis"
  gem.authors = ["Maximialiano Gonzalez", "Esteban Pastorino"]

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  gem.require_paths = ["lib"]

  gem.add_dependency 'redis', ['~> 2.2.2']

  gem.version = Dconfig::VERSION
end
