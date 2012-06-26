class UserController < ApplicationController
  def index
    show_work
    render :action => 'show_work'
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
    end
    if @user.role_proofer == true
      @avail_proofs = EbyDef.count(:conditions => "assignedto IS NULL AND status = 'NeedProof'")
      # TODO: break this down by proofing round?
      @inprog_proofs = EbyDef.find(:all, :conditions => "status = 'NeedProof' and assignedto = #{@user.id}")
    end
    if @user.role_fixer == true
      cond_string = 'false '
      ['does_arabic', 'does_greek', 'does_russian', 'does_extra'].each { |which|
        cond_string += 'or '+which.sub('does_','')+"='todo' " if(@user.read_attribute(which) == true)
      }
      @avail_fixups = EbyDef.count(:conditions => "assignedto IS NULL AND status = 'NeedFixup' and ( "+cond_string+" )")
      @inprog_fixups = EbyDef.find(:all, :conditions => "status = 'NeedFixup' and assignedto = #{@user.id}")
    end
    if @user.role_publisher == true
      @avail_publish = EbyDef.count(:conditions => "assignedto IS NULL AND status = 'NeedPublish'")
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
end
