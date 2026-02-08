ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'logger' # Fix for Ruby 3.2+ compatibility
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
