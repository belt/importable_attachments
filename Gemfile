source 'http://rubygems.org'
# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# Declare your gem's dependencies in importable_attachments.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem 'rubygems-bundler'

# jquery-rails is used by the dummy application
gem 'jquery-rails'

# needed by the models (to test against the dummy app)
gem 'configuration'
gem 'smarter_dates'
gem 'rails-mark_requirements'
gem 'rails-alpha_numeric_validator'
gem 'ruby-filemagic'

# needed by the controllers (to test against the dummy app)
gem 'haml-rails'
gem 'formtastic'

group :development, :test do
  gem 'debugger'

  # needed by the models simply to run rspec
  gem 'valid_attribute'
  gem 'machinist'
  gem 'rspec-paper_trail'
  gem 'cucumber-rails', require: false
  gem 'capybara', '< 2.0.0'
  gem 'poltergeist', '< 1.1.0', require: 'capybara/poltergeist'
end
