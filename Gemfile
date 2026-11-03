source 'https://rubygems.org'

# Those two gems were part of ruby, but was removed in 3.4.0. Perhaps we can remove them after upgrading rails version
gem 'mutex_m'
gem 'csv'

gem 'concurrent-ruby', '1.3.4' # can be removed after rails upgrade
gem 'logger', '1.6.4' # can be removed after rails upgrade

gem 'rails', '~> 6.1'
gem 'omniauth-google-oauth2'
gem "omniauth-rails_csrf_protection"

gem 'marcel','~>1'
gem 'activerecord-session_store'
gem 'activerecord_where_assoc', '~> 1.0' # for scopes about associations

gem 'rufus-scheduler' # scheduler
gem 'sentry-rails'

gem 'mysql2'
gem 'sqlite3' # used by some rake tasks (for exports?)
gem 'json', '>=1.7.7'
gem 'nokogiri'
gem 'clockwork' # scheduler
gem 'hebrew', '>=0.2.6' # for naive_full_nikkud
gem 'puma'
gem 'hamlit-rails'
gem 'haml'
gem 'htmlentities'
gem 'sass-rails'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'mini_racer'
gem 'rexml'
gem 'globalid', '~> 1.0'
gem 'bootsnap'

# To use debugger
group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.0'
end

group :development do
  gem 'listen'
  gem 'byebug'
  gem 'web-console' #, '~> 2.0'
end

group :test do
  gem 'drb' # This gem was excluded from ruby 3.4. Perhaps can be removed after Rails version upgrade.
  gem 'shoulda-matchers', '~> 5.3'
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'vcr', '~> 6.1'
  gem 'webmock', '~> 3.18'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'timecop', '~> 0.9'
  gem 'capybara', '~> 3.39'
  gem 'selenium-webdriver'
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
