Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, AppConstants.google_oauth_client_id, AppConstants.google_oauth_client_secret
  provider :developer if Rails.env == 'development'
end
