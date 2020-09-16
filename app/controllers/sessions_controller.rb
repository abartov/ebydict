class SessionsController < ApplicationController
  def new
  end

  def create
    # Get access tokens from the google server
    access_token = auth_hash
    @user = EbyUser.from_omniauth(access_token)
    # Access_token is used to authenticate request made from the rails application to the google server
    @user.google_token = access_token.credentials.token
    # Refresh_token to request new access_token
    # Note: Refresh_token is only sent once during the first request
    refresh_token = access_token.credentials.refresh_token
    @user.google_refresh_token = refresh_token if refresh_token.present?
    reset_session
    session['user'] = @user
    @user.login_count = 0 if @user.login_count.nil?
    @user.login_count += 1
    @user.last_login = Time.now.to_datetime
    @user.save!
    session['user_id'] = @user.id
    @current_user = @user
    redirect_to '/'
  end

  def failure
  end

  def destroy
    session['user_id'] = nil
    session['user'] = nil
    redirect_to '/'
  end

   protected

   def auth_hash
    request.env['omniauth.auth']
  end
  private
  def secure?
    false
  end
end
