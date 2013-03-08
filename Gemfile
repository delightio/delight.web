source 'https://rubygems.org'

gem 'rails'
gem 'thin'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Replace IRB with Pry even in produciton environment
gem 'pry-rails'

gem 'pg'
gem 'activerecord-postgres-hstore'
gem 'aws-sdk'
gem 'redis'
gem 'redis-objects'
gem 'resque'

gem 'hirefireapp'

# emailing with mailgun
gem 'rest-client'
gem 'mailgun-rails'

gem 'plist'

group :development, :test do
  gem 'rspec-rails', "2.12.0"
  gem 'factory_girl_rails', "~> 4.0"
end

group :test do
  gem "factory_girl_rails", "~> 4.0"
  gem "capybara"
  gem "guard-rspec"
  gem "rspec-prof" #https://github.com/sinisterchipmunk/rspec-prof
  gem 'database_cleaner'
  gem 'spork', '~> 1.0rc'
  gem 'guard-spork'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
  gem 'compass-rails'
end

gem "therubyracer"
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem "twitter-bootstrap-rails"

gem 'jquery-rails'


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

# Signin
gem 'devise'

# OAuth
gem 'omniauth-twitter'
gem 'omniauth-github'

gem 'newrelic_rpm'

gem 'exceptional'

gem "kaminari" # for pagination
gem "simple_form"
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'

gem 'plist'
gem 'json'
