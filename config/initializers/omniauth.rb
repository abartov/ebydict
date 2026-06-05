require 'deployment_helpers'

unless DeploymentHelpers.assets_compilation?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, SiteConstants::GOOGLE_OAUTH_CLIENT_ID, SiteConstants::GOOGLE_OAUTH_CLIENT_SECRET
    provider :developer if Rails.env == 'development'
  end
end
