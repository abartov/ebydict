# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = Rails.root.join('spec', 'vcr_cassettes')
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_localhost = true

  # Filter sensitive data
  config.filter_sensitive_data('<GOOGLE_OAUTH_CLIENT_ID>') do
    Rails.application.config.constants['google_oauth_client_id']
  end

  config.filter_sensitive_data('<GOOGLE_OAUTH_CLIENT_SECRET>') do
    Rails.application.config.constants['google_oauth_client_secret']
  end

  # Allow real HTTP connections in development for recording cassettes
  config.allow_http_connections_when_no_cassette = false

  # Ignore AWS S3 requests (we'll stub these separately)
  config.ignore_hosts 's3.amazonaws.com', /.*\.s3\.amazonaws\.com/
end
