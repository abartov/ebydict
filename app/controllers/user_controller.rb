class UserController < ApplicationController
  before_action :login_required

  def index
    show_work
    render :action => 'show_work'
  end
  def list
    redirect_to :controller => 'user' unless check_role('publisher')
    @page_title = I18n.t(:admin_userlist)
    @users = EbyUser.order(:fullname).page(params[:page])
  end
  def active_emails
    redirect_to :controller => 'user' unless check_role('publisher')
    @page_title = I18n.t(:admin_emailusers)
    active_users = EbyDefEvent.where("updated_at > ?", 6.months.ago).pluck(:who)
    emails = EbyUser.where("last_login > ?", 3.months.ago).pluck(:email) # gather recent logins
    # but also anyone who's completed work in past 3 months, even if they've maintained a single login for more than 3 month! :)
    emails += EbyUser.find(active_users).map(&:email)
    @emails = emails.uniq.join(', ')
  end
  def show_work
    @page_title = t(:user_maintitle)
    @user = session['user']
    # calculate available work bits according to user's role
    if @user.role_partitioner == true
      @avail_scanimgs = EbyScanImage.where(assignedto: nil, status: 'NeedPartition').count
      @inprog_scanimgs = EbyScanImage.where(assignedto: @user.id)
      @avail_colimgs = EbyColumnImage.where(assignedto: nil, status: 'NeedPartition').count
      @inprog_colimgs = EbyColumnImage.where(status: 'NeedPartition', assignedto: @user.id)

      # TODO: calculate which volumes are COMPLETELY PARTITIONED INTO COLUMNS and ready for def partitioning
      #parted_vols = EbyColumnImage.find
      # TODO: change query below to only include coldefimgs from COMPLETELY PARTITIONED volumes
      @avail_coldefimgs = EbyColumnImage.where(assignedto: nil, status: 'NeedDefPartition').count
      @inprog_coldefimgs = EbyColumnImage.where(status: 'NeedDefPartition', assignedto: @user.id)
    end
    if @user.role_typist == true
      @avail_defs = EbyDef.where(assignedto: nil, status: 'NeedTyping').count
      @inprog_defs = EbyDef.where(status: 'NeedTyping', assignedto: @user.id)
      @avail_defs_small = EbyDef.count_by_action_and_size(@user, AppConstants.type, 'small', nil)
      @avail_defs_medium = EbyDef.count_by_action_and_size(@user, AppConstants.type, 'medium', nil)
      @avail_defs_large = EbyDef.count_by_action_and_size(@user, AppConstants.type, 'large', nil)
    end
    if @user.role_proofer == true
      @avail_proofs = {}
      ['small', 'medium', 'large'].each do |size|
        @avail_proofs[size] = ''
        (1..@user.max_proof_level).each do |round|
          @avail_proofs[size] += "#{I18n.t(:type_round)} #{round}: #{EbyDef.count_by_action_and_size(@user, AppConstants.proof, size, round)}; "
        end
      end
      #@avail_proofs = EbyDef.count(:conditions => "assignedto IS NULL AND status = 'NeedProof'")
      # TODO: break this down by proofing round?
      @inprog_proofs = EbyDef.where(status: 'NeedProof', assignedto: @user.id)
      @avail_aliases = EbyDef.where(aliases_done: [nil, false]).count
    end
    if @user.role_fixer == true
      cond_string = "? "
      ['does_arabic', 'does_greek', 'does_russian', 'does_extra'].each { |which|
        cond_string += 'or '+which.sub('does_','')+"='todo' " if(@user.read_attribute(which) == true)
      }
      @avail_fixups = EbyDef.where(["assignedto IS NULL AND status = 'NeedFixup' and ( #{cond_string} )", 0]).count
      @inprog_fixups = EbyDef.where(status: 'NeedFixup', assignedto: @user.id)
    end
    if @user.role_publisher == true
      @avail_publish = EbyDef.where(assignedto: nil, status: 'NeedPublish').count
      @avail_problem = EbyDef.where(assignedto: nil, status: 'Problem').count
    end
  end
  def prefs
    @user = EbyUser.find(session["user"])
  end
  def edit # admin action
    if check_role('publisher')
      @user = EbyUser.find(params[:id])
    else
      redirect_to :controller => :user
    end
  end
  def update # admin action
    if check_role('publisher')
      begin
        u = EbyUser.find(params[:id])
        u.assign_attributes(user_params)
        u.password = EbyUser.hashfunc(params['new_password']) unless params['new_password'].empty?
        u.save!

        flash[:notice] = "User #{u.login} successfully edited!"
      rescue
        flash[:error] = "Failed to update user!"
      end
    end
    redirect_to :controller => 'user'
  end
  def chpwd
    p = params[:password]
    if p.nil? or p.empty?
      flash[:error] = t(:user_empty_pwd)
    else
      @user = EbyUser.find(session["user"])
      @user.password = EbyUser.hashfunc(p)
      @user.save!
      flash[:notice] = t(:user_pwd_changed)
    end
    index
  end
  def show
    @user = EbyUser.find(session[:user].id) # deliberately don't use the session EbyUser instance, to force fresh associations.  TODO: this is inelegant, but I couldn't be bothered to find out why it wasn't refreshed
    if @user.role_publisher and (params[:id] != nil and not params[:id].empty?)
      @user = EbyUser.find(params[:id]) # only admins can look at other users
    end
  end
end
private
def user_params
  params.require('eby_user').permit!
end