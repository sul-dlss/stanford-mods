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

  gem.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency 'mods'
  
  # Runtime dependencies
  # gem.add_runtime_dependency 'nokogiri'

  # Development dependencies
  # Bundler WILL install these gems too if you've checked out from git and run 'bundle install'
  # Bundler WILL NOT add these as dependencies if you gem install or add this gem to your Gemfile
  gem.add_development_dependency "rake"
  # docs
  gem.add_development_dependency "rdoc"
  gem.add_development_dependency "yard"
  # tests
  gem.add_development_dependency 'rspec'
  # using coveralls with travis now
  # gem.add_development_dependency 'simplecov'
  # gem.add_development_dependency 'simplecov-rcov'
  # gem.add_development_dependency 'ruby-debug19'

end
