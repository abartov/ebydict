class UserController < ApplicationController
  def index
    show_work
    render :action => 'show_work'
  end
  def list
    redirect_to :controller => 'user' unless check_role('publisher')
    @page_title = I18n.t(:admin_userlist)
    @users = EbyUser.page(params[:page])
  end
  def active_emails
    redirect_to :controller => 'user' unless check_role('publisher')
    @page_title = I18n.t(:admin_emailusers)
    emails = EbyUser.where("last_login > ?", 3.months.ago).pluck(:email) # gather recent logins
    # but also anyone who's completed work in past 3 months, even if they've maintained a single login for more than 3 month! :)
    active_users = EbyDef.where("updated_at > ?", 3.months.ago).pluck(:assignedto)
    emails += ', '+EbyUser.find(active_users).map(&:email)
    @emails = emails.uniq.join(', ')
  end
  def show_work
    @page_title = t(:user_maintitle)
    @user = EbyUser.find(session["user"])
    
    # calculate available work bits according to user's role
    if @user.role_partitioner == true
      @avail_scanimgs = EbyScanImage.count(:conditions => "assignedto IS NULL AND status = 'NeedPartition'")
      @inprog_scanimgs = EbyScanImage.find(:all, :conditions => "assignedto = #{@user.id}")
      @avail_colimgs = EbyColumnImage.count(:conditions => "assignedto IS NULL AND status = 'NeedPartition'")
      @inprog_colimgs = EbyColumnImage.find(:all, :conditions => "status = 'NeedPartition' and assignedto = #{@user.id}")

      # TODO: calculate which volumes are COMPLETELY PARTITIONED INTO COLUMNS and ready for def partitioning
      #parted_vols = EbyColumnImage.find
      # TODO: change query below to only include coldefimgs from COMPLETELY PARTITIONED volumes
      @avail_coldefimgs = EbyColumnImage.count(:conditions => "assignedto IS NULL AND status = 'NeedDefPartition'")
      @inprog_coldefimgs = EbyColumnImage.find(:all, :conditions => "status = 'NeedDefPartition' and assignedto = #{@user.id}")
    end
    if @user.role_typist == true
      @avail_defs = EbyDef.count(:conditions => "assignedto IS NULL AND status = 'NeedTyping'")
      @inprog_defs = EbyDef.find(:all, :conditions => "status = 'NeedTyping' and assignedto = #{@user.id}")
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
      @inprog_proofs = EbyDef.find(:all, :conditions => "status = 'NeedProof' and assignedto = #{@user.id}")
    end
    if @user.role_fixer == true
      cond_string = "? "
      ['does_arabic', 'does_greek', 'does_russian', 'does_extra'].each { |which|
        cond_string += 'or '+which.sub('does_','')+"='todo' " if(@user.read_attribute(which) == true)
      }
      @avail_fixups = EbyDef.count(:conditions => ["assignedto IS NULL AND status = 'NeedFixup' and ( #{cond_string} )", 0])
      @inprog_fixups = EbyDef.find(:all, :conditions => "status = 'NeedFixup' and assignedto = #{@user.id}")
    end
    if @user.role_publisher == true
      @avail_publish = EbyDef.count(:conditions => "assignedto IS NULL AND status = 'NeedPublish'")
      @avail_problem = EbyDef.count(:conditions => "assignedto IS NULL AND status = 'Problem'")
    end
  end
  def prefs
    @user = EbyUser.find(session["user"])
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
