source 'https://rubygems.org'

gem 'rails', '3.2.1'
gem 'thin'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'aws-sdk'
gem 'redis'
gem 'redis-objects'
gem 'resque'

# emailing with mailgun
gem 'rest-client'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem "guard-rspec"
  gem "rspec-prof" #https://github.com/sinisterchipmunk/rspec-prof
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'guard-cucumber'
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
  gem "twitter-bootstrap-rails"
end

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

gem "kaminari" # for pagination
gem "simple_form"
