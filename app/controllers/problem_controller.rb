class ProblemController < ApplicationController
  before_filter :check_the_roles

  def list
    @probs = EbyDef.where(:status => 'Problem', :assignedto => nil).page(params[:page])
  end

  def resolve
  end
  protected
  def check_the_roles
    return check_role('publisher')
  end
end
