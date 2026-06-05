# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Login', type: :request do
  describe 'GET /login/login' do
    it 'renders the login page' do
      get '/login/login'
      expect(response).to have_http_status(:success)
    end

    it 'does not require authentication' do
      get '/login/login'
      expect(response).not_to redirect_to('/login/login')
    end

    context 'when user is already logged in' do
      it 'redirects to user controller' do
        user = create(:eby_user, login: 'loggedinuser')
        login_as(user)

        get '/login/login'
        expect(response).to redirect_to('/user/index')
      end
    end
  end

  describe 'POST /login/do_login' do
    context 'with valid credentials' do
      let!(:user) { create(:eby_user, login: 'testuser', password: EbyUser.hashfunc('password123')) }

      it 'logs the user in' do
        post '/login/do_login', params: {
          username: 'testuser',
          password: 'password123'
        }

        expect(response).to redirect_to('/user/index')
        expect(flash[:notice]).to eq('Login successful!')
      end

      it 'increments login count' do
        initial_count = user.login_count || 0

        post '/login/do_login', params: {
          username: 'testuser',
          password: 'password123'
        }

        user.reload
        expect(user.login_count).to eq(initial_count + 1)
      end

      it 'updates last login timestamp' do
        post '/login/do_login', params: {
          username: 'testuser',
          password: 'password123'
        }

        user.reload
        expect(user.last_login).to be_present
        expect(user.last_login).to be_within(1.minute).of(Time.now.to_datetime)
      end

      it 'allows access to protected pages after login' do
        post '/login/do_login', params: {
          username: 'testuser',
          password: 'password123'
        }

        # Now try to access a protected page (user controller)
        follow_redirect!
        expect(response).to have_http_status(:success)
      end
    end

    context 'with invalid credentials' do
      let!(:user) { create(:eby_user, login: 'testuser', password: EbyUser.hashfunc('password123')) }

      it 'redirects back to login with wrong password' do
        post '/login/do_login', params: {
          username: 'testuser',
          password: 'wrongpassword'
        }

        expect(response).to redirect_to('/login/login')
        expect(flash[:notice]).to eq('Unknown user or bad password!')
      end

      it 'redirects back to login with unknown user' do
        post '/login/do_login', params: {
          username: 'nonexistent',
          password: 'password123'
        }

        expect(response).to redirect_to('/login/login')
        expect(flash[:notice]).to eq('Unknown user or bad password!')
      end
    end

    context 'with missing parameters' do
      it 'redirects back to login when username is missing' do
        post '/login/do_login', params: {
          password: 'password123'
        }

        expect(response).to redirect_to('/login/login')
        expect(flash[:notice]).to eq('please specify login name and password')
      end

      it 'redirects back to login when password is missing' do
        post '/login/do_login', params: {
          username: 'testuser'
        }

        expect(response).to redirect_to('/login/login')
        expect(flash[:notice]).to eq('please specify login name and password')
      end

      it 'redirects back to login when both are missing' do
        post '/login/do_login', params: {}

        expect(response).to redirect_to('/login/login')
        expect(flash[:notice]).to eq('please specify login name and password')
      end
    end
  end

  describe 'GET /login/logout' do
    it 'clears the session' do
      user = create(:eby_user, login: 'logoutuser')
      login_as(user)

      get '/login/logout'

      expect(response).to have_http_status(:success)
      expect(flash[:notice]).to eq('Logout successful!')
    end

    it 'renders the login page' do
      user = create(:eby_user, login: 'renderuser')
      login_as(user)

      get '/login/logout'

      expect(response).to render_template(:login)
    end

    it 'can be called when not logged in' do
      get '/login/logout'

      expect(response).to have_http_status(:success)
    end

    it 'prevents access to protected pages after logout' do
      user = create(:eby_user, login: 'protecteduser')
      login_as(user)

      get '/login/logout'

      # Try to access a protected page - should redirect to login
      get '/user/index'
      # After logout, protected pages should require re-authentication
      expect(response).to redirect_to('/login/login')
    end
  end

  describe 'authentication flow' do
    it 'allows full login/logout cycle' do
      user = create(:eby_user, login: 'cycleuser', password: EbyUser.hashfunc('pass123'))

      # Login
      post '/login/do_login', params: {
        username: 'cycleuser',
        password: 'pass123'
      }
      expect(response).to redirect_to('/user/index')
      expect(flash[:notice]).to eq('Login successful!')

      # Verify logged in
      follow_redirect!
      expect(response).to have_http_status(:success)

      # Logout
      get '/login/logout'
      expect(response).to have_http_status(:success)
      expect(flash[:notice]).to eq('Logout successful!')
    end

    it 'increments login count on each login' do
      user = create(:eby_user, login: 'countuser', password: EbyUser.hashfunc('pass123'), login_count: 5)

      post '/login/do_login', params: {
        username: 'countuser',
        password: 'pass123'
      }

      user.reload
      expect(user.login_count).to eq(6)

      # Logout and login again
      get '/login/logout'

      post '/login/do_login', params: {
        username: 'countuser',
        password: 'pass123'
      }

      user.reload
      expect(user.login_count).to eq(7)
    end
  end

  describe 'secure? override' do
    it 'does not require login for login actions' do
      # Login page should be accessible without being logged in
      get '/login/login'
      expect(response).to have_http_status(:success)
      expect(response).not_to redirect_to('/login/login')
    end
  end
end
