class LoginController < ApplicationController

  def index
    login
    render :action => 'login'
  end
  def login
    @page_title = "EbyDict: Login"
    if not session['user'].nil?
      redirect_to :controller => 'user'
    end
  end
  def do_login
    ulogin = params[:username]
    upassword = params[:password]
    if ulogin.nil? || upassword.nil? 
      redirect_to :action => 'login'
      flash[:notice] = "please specify login name and password"
    else
      # look up the user
      user = EbyUser.authenticate(ulogin, upassword)
      if user.nil? || user == false
        redirect_to :action => 'login'
        flash[:notice] = "Unknown user or bad password!"
      else
        # login successful!
        session['user'] = user
        user.login_count = 0 if user.login_count.nil?
        user.login_count += 1
        user.last_login = Time.now.to_datetime
        user.save!
        flash[:notice] = "Login successful!"
        redirect_to :controller => 'user'
      end
    end
  end
  def logout
    session['user'] = nil # forget session
    reset_session
    flash[:notice] = "Logout successful!"
    render :action => 'login'
  end
  
  private
  def secure?
    false
  end
end
