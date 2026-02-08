# frozen_string_literal: true

module RequestHelpers
  # Helper to log in a user for request specs by actually performing the login
  # This creates a real session just like a user would
  def login_as(user, password: 'password123')
    post '/login/do_login', params: {
      username: user.login,
      password: password
    }
    # Follow the redirect to complete the login
    follow_redirect! if response.redirect?
    user
  end

  # Helper to log in via OAuth (for testing OAuth flow)
  def oauth_login_as(user)
    # Stub the OAuth callback
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: 'google_oauth2',
      uid: user.provider_uid || '123456',
      info: {
        email: user.email,
        name: user.fullname
      },
      credentials: {
        token: 'mock_token',
        refresh_token: 'mock_refresh_token'
      }
    })
  end

  # Helper to simulate being logged out
  def logout
    get '/login/logout'
  end

  # Check if currently logged in (by checking for redirect to login)
  def logged_in?
    get '/user'
    !response.redirect? || !response.location.include?('/login')
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request

  # Reset OmniAuth after each test
  config.after(:each, type: :request) do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end
end
