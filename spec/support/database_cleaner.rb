# frozen_string_literal: true

require 'database_cleaner/active_record'
require 'rake'

RSpec.configure do |config|
  config.before(:suite) do
    # Ensure test database is set up (SQLite-compatible)
    unless ActiveRecord::Base.connection.table_exists?(:eby_users)
      puts "Setting up test database..."
      Rails.application.load_tasks
      Rake::Task['test_db:setup'].invoke
    end

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    # Use truncation for system tests, transaction for everything else
    if example.metadata[:type] == :system
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end

    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
