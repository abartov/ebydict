source 'https://rubygems.org'

gem 'logger' # Fix for Ruby 3.2+ compatibility
gem 'rails', '~>6.0'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
#gem 'rake', '=0.9.2.2'
gem 'omniauth-google-oauth2'
gem "omniauth-rails_csrf_protection"

gem 'marcel','~>1'
gem 'activerecord-session_store'
gem 'activerecord_where_assoc', '~> 1.0' # for scopes about associations

gem 'mysql2'
gem 'json', '>=1.7.7'
gem 'nokogiri'
gem 'clockwork' # scheduler
gem 'hebrew', '>=0.2.6' # for naive_full_nikkud
#gem 'dispatcher'
gem 'puma'
#gem 'thin'
gem 'hamlit-rails'
gem 'haml'
gem 'htmlentities'
gem 'sass-rails'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
#gem 'therubyracer'
gem 'mini_racer'
gem 'rexml'
gem 'globalid', '~> 1.0'
# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
group :development, :test do
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.0'
end

group :development do
  gem 'listen'
  gem 'bootsnap', require: false
  gem 'byebug'
  gem 'sqlite3' # enable for dev, if you like
  gem 'web-console' #, '~> 2.0'
end

group :test do
  gem 'shoulda-matchers', '~> 5.3'
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'simplecov', require: false
  gem 'vcr', '~> 6.1'
  gem 'webmock', '~> 3.18'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'timecop', '~> 0.9'
  gem 'capybara', '~> 3.39'
  gem 'selenium-webdriver'
end

group :production do
  gem 'puma-daemon'
end
gem 'rmagick', '~> 5.3' # TODO: migrate away from this to mini_magick
gem 'mini_magick' # for activestorage analysis providing height/width for canvas
gem 'will_paginate'
gem 'tinymce-rails', '~> 5.0' # 6.x changed the toolbar layout and I couldn't be bothered to figure out the change
gem 'tinymce-rails-langs'
gem 'rmultimarkdown'
gem 'test-unit'
gem 'aws-sdk-s3', require: false
gem 'http'
