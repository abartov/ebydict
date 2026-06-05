# frozen_string_literal: true

# FactoryBot configuration
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # Lint factories in development to catch errors early
  config.before(:suite) do
    if Rails.env.development?
      begin
        DatabaseCleaner.start
        FactoryBot.lint
      ensure
        DatabaseCleaner.clean
      end
    end
  end
end
