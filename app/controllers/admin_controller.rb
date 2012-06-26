class AdminController < ApplicationController
  # methods
  def changes
    if check_role('publisher')
      @changes = query_changes
      render :action => 'changes'
    else
      redirect_to :controller => 'user'
    end
  end
  def adduser
    if check_role('publisher')
      render :action => 'adduser'
    else
      redirect_to :controller => 'user'
    end
  end
  def doadduser
    if check_role('publisher')
      begin
        u = EbyUser.new(params[:eby_user])
        clear_pwd = u.password
        u.password = EbyUser.hashfunc(clear_pwd)
        u.save!
        Notifications.signup(u, clear_pwd).deliver

        flash[:notice] = "User #{u.login} successfully added!"
      rescue
        flash[:error] = "Failed to create user!"
      end
    end
    redirect_to :controller => 'user'
  end
  # pure logic
  def query_changes
    evts = EbyDefEvent.find(:all, :limit => 50, :order => 'created_at DESC')
    return evts
  end
end
