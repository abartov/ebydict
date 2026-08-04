# frozen_string_literal: true

require 'deployment_helpers'

unless DeploymentHelpers.assets_compilation?
  module SiteConstants
    GOOGLE_OAUTH_CLIENT_ID = ENV.fetch('GOOGLE_OAUTH_CLIENT_ID')
    GOOGLE_OAUTH_CLIENT_SECRET = ENV.fetch('GOOGLE_OAUTH_CLIENT_SECRET')
    SCAN_URL_BASE = ENV.fetch('SCAN_URL_BASE')
    PUB_URL_BASE = ENV.fetch('PUB_URL_BASE')
  end
end