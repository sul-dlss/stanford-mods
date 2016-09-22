# -*- encoding: utf-8 -*-
require File.expand_path('../lib/stanford-mods/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "stanford-mods"
  gem.version       = Stanford::Mods::VERSION
  gem.authors       = ["Naomi Dushay", "Bess Sadler"]
  gem.email         = ["ndushay AT stanford.edu", "bess AT stanford.edu"]
  gem.description   = "Stanford specific wrangling of MODS metadata from DOR, the Stanford Digital Object Repository"
  gem.summary       = "Stanford specific wrangling of MODS metadata"
  gem.homepage      = "https://github.com/sul-dlss/stanford-mods"

  gem.extra_rdoc_files = ["LICENSE", "README.md"]
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'mods', '~> 2.0', '>= 2.0.2'
  # active_support for .ordinalize, eg. 1 -> 1st, 2 -> 2nd for centuries
  gem.add_dependency 'activesupport'

  # Development dependencies
  gem.add_development_dependency "rake"
  # docs
  gem.add_development_dependency "rdoc"
  gem.add_development_dependency "yard"
  # tests
  gem.add_development_dependency 'rspec'
end
