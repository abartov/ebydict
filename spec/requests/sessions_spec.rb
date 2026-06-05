# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  before do
    # Enable OmniAuth test mode
    OmniAuth.config.test_mode = true
  end

  after do
    # Clean up after each test
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  describe 'GET /login' do
    it 'renders the OAuth login page' do
      get '/login'
      expect(response).to have_http_status(:success)
    end

    it 'does not require authentication' do
      get '/login'
      expect(response).not_to redirect_to('/login/login')
    end
  end

  describe 'GET /auth/google_oauth2/callback' do
    context 'with valid OAuth credentials for existing user' do
      let!(:user) do
        create(:eby_user,
               provider: 'google_oauth2',
               uid: '123456789',
               email: 'existing@example.com',
               fullname: 'Existing User')
      end

      before do
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '123456789',
          info: {
            email: 'existing@example.com',
            name: 'Existing User'
          },
          credentials: {
            token: 'mock_access_token',
            refresh_token: 'mock_refresh_token'
          }
        })
      end

      it 'logs the user in' do
        get '/auth/google_oauth2/callback'

        expect(response).to redirect_to('/')
      end

      it 'updates Google tokens' do
        get '/auth/google_oauth2/callback'

        user.reload
        expect(user.google_token).to eq('mock_access_token')
        expect(user.google_refresh_token).to eq('mock_refresh_token')
      end

      it 'increments login count' do
        initial_count = user.login_count || 0

        get '/auth/google_oauth2/callback'

        user.reload
        expect(user.login_count).to eq(initial_count + 1)
      end

      it 'updates last login timestamp' do
        get '/auth/google_oauth2/callback'

        user.reload
        expect(user.last_login).to be_present
        expect(user.last_login).to be_within(1.minute).of(Time.now.to_datetime)
      end

      it 'stores user in session' do
        get '/auth/google_oauth2/callback'

        # Verify by following redirect and checking no further auth required
        follow_redirect!
        expect(response).to have_http_status(:success)
      end
    end

    context 'with valid OAuth credentials for new user' do
      before do
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '987654321',
          info: {
            email: 'newuser@example.com',
            name: 'New User'
          },
          credentials: {
            token: 'new_mock_access_token',
            refresh_token: 'new_mock_refresh_token'
          }
        })
      end

      it 'creates a new user' do
        expect {
          get '/auth/google_oauth2/callback'
        }.to change(EbyUser, :count).by(1)
      end

      it 'sets user attributes from OAuth data' do
        get '/auth/google_oauth2/callback'

        new_user = EbyUser.find_by(uid: '987654321')
        expect(new_user).to be_present
        expect(new_user.provider).to eq('google_oauth2')
        expect(new_user.email).to eq('newuser@example.com')
        expect(new_user.fullname).to eq('New User')
      end

      it 'sets Google tokens for new user' do
        get '/auth/google_oauth2/callback'

        new_user = EbyUser.find_by(uid: '987654321')
        expect(new_user.google_token).to eq('new_mock_access_token')
        expect(new_user.google_refresh_token).to eq('new_mock_refresh_token')
      end

      it 'initializes login count to 1' do
        get '/auth/google_oauth2/callback'

        new_user = EbyUser.find_by(uid: '987654321')
        expect(new_user.login_count).to eq(1)
      end

      it 'logs the new user in' do
        get '/auth/google_oauth2/callback'

        expect(response).to redirect_to('/')
      end
    end

    context 'without refresh token (subsequent logins)' do
      let!(:user) do
        create(:eby_user,
               provider: 'google_oauth2',
               uid: '111222333',
               google_refresh_token: 'existing_refresh_token')
      end

      before do
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '111222333',
          info: {
            email: user.email,
            name: user.fullname
          },
          credentials: {
            token: 'new_access_token',
            refresh_token: nil  # Not sent on subsequent logins
          }
        })
      end

      it 'updates access token but preserves refresh token' do
        get '/auth/google_oauth2/callback'

        user.reload
        expect(user.google_token).to eq('new_access_token')
        expect(user.google_refresh_token).to eq('existing_refresh_token')
      end
    end
  end

  describe 'GET /sessions/destroy' do
    it 'logs the user out' do
      user = create(:eby_user)
      login_as(user)

      get '/sessions/destroy'

      expect(response).to redirect_to('/')
    end

    it 'clears user_id from session' do
      user = create(:eby_user)
      login_as(user)

      get '/sessions/destroy'

      # Verify logout by trying to access protected resource
      get '/user/index'
      expect(response).to redirect_to('/login/login')
    end

    it 'clears user from session' do
      user = create(:eby_user)
      login_as(user)

      get '/sessions/destroy'

      # Session should be cleared
      expect(response).to redirect_to('/')
    end

    it 'can be called when not logged in' do
      get '/sessions/destroy'

      expect(response).to redirect_to('/')
    end
  end

  describe 'GET /sessions/failure' do
    it 'renders failure page' do
      get '/sessions/failure'
      expect(response).to have_http_status(:success)
    end

    it 'does not require authentication' do
      get '/sessions/failure'
      expect(response).not_to redirect_to('/login/login')
    end
  end

  describe 'OAuth flow integration' do
    it 'allows complete OAuth login and logout cycle' do
      # Setup OAuth mock
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '555666777',
        info: {
          email: 'oauth@example.com',
          name: 'OAuth User'
        },
        credentials: {
          token: 'oauth_token',
          refresh_token: 'oauth_refresh'
        }
      })

      # OAuth login
      get '/auth/google_oauth2/callback'
      expect(response).to redirect_to('/')

      # Verify user was created and logged in
      user = EbyUser.find_by(uid: '555666777')
      expect(user).to be_present
      expect(user.login_count).to eq(1)

      # Logout
      get '/sessions/destroy'
      expect(response).to redirect_to('/')
    end

    it 'handles multiple logins correctly' do
      user = create(:eby_user,
                   provider: 'google_oauth2',
                   uid: '888999000',
                   login_count: 10)

      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '888999000',
        info: {
          email: user.email,
          name: user.fullname
        },
        credentials: {
          token: 'token1',
          refresh_token: 'refresh1'
        }
      })

      # First login
      get '/auth/google_oauth2/callback'
      user.reload
      expect(user.login_count).to eq(11)

      # Logout
      get '/sessions/destroy'

      # Second login
      get '/auth/google_oauth2/callback'
      user.reload
      expect(user.login_count).to eq(12)
    end
  end

  describe 'secure? override' do
    it 'does not require login for sessions actions' do
      # All session actions should be accessible without auth
      get '/login'
      expect(response).to have_http_status(:success)

      get '/sessions/failure'
      expect(response).to have_http_status(:success)

      get '/sessions/destroy'
      expect(response).to redirect_to('/')  # Redirects but doesn't require auth
    end
  end
end
