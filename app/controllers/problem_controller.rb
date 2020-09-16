class ProblemController < ApplicationController
  before_action :login_required
  before_action :check_the_roles

  def list
    @probs = EbyDef.where(:status => 'Problem', :assignedto => nil).page(params[:page])
    @my_probs = EbyDef.where(:status => 'Problem', :assignedto => session['user'].id)
  end
  def tackle
    d = EbyDef.find(params[:id])
    d.assignee = session['user']
    d.save!
    redirect_to :controller => 'type', :action => 'edit', :id => d
  end
  def resolve
  end
  protected
  def check_the_roles
    return check_role('publisher')
  end
end
