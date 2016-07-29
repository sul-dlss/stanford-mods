source 'https://rubygems.org'

# See stanford-mods.gemspec for this gem's dependencies
gemspec

group :test, :development do
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'pry-byebug', require: false, platform: [:ruby_20, :ruby_21]
end

group :test do
  gem 'coveralls', require: false
#  gem 'pry-byebug', require: false
end

# Pin to activesupport 4.x for older versions of ruby
gem 'activesupport', '~> 4.2' if RUBY_VERSION < '2.2.2'
