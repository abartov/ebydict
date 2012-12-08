class TypeController < ApplicationController

  before_filter :check_the_roles

  def index
    list
    render :action => 'list'
  end
  def list # TODO: what does this mean for this controller?
    #edit
  end
  def get_fixup
    unless(check_role('fixer'))
      flash[:error] = t(:type_notfixer)
      redirect_to :controller => 'user'
    else
      call_assign_def_by_size(params[:defsize], AppConstants.fixup)
    end
  end
  def get_proof
    unless(check_role('proofer'))
      flash[:error] = t(:type_notproofer)
      redirect_to :controller => 'user'
    else
      call_assign_def_by_size(params[:defsize], AppConstants.proof)
    end
  end
  def get_def
    unless(check_role('typist'))
      flash[:error] = t(:type_nottypist)
      redirect_to :controller => 'user'
    else
      call_assign_def_by_size(params[:defsize], AppConstants.type)
    end
  end
  def proof
    unless(check_role('proofer'))
      flash[:error] = t(:type_notproofer)
      redirect_to :controller => 'user'
    else
      if @thedef.nil?
        @thedef = EbyDef.find_by_id(params[:id])
      end
      if @thedef.nil? or @thedef.proof_round_passed >= session['user'].max_proof_level
        flash[:error] = t(:type_proofround_toohigh, :round => (@thedef.proof_round_passed+1).to_s)
        redirect_to :controller => 'user'
      else
        edit
      end
    end
  end
  def edit
    if @thedef.nil?
      @thedef = EbyDef.find_by_id(params[:id])
    end
    if @thedef.nil?
      flash[:error] = t(:type_defnotfound)
      redirect_to :controller => 'user'
      return
    elsif not check_role('publisher') and not is_assignee(@thedef)
      flash[:error] = t(:type_defnotyours)
      redirect_to :controller => 'user'
      return
    else
      # prepare defpart images for client-side JS to handle
      @parts_js = "var parts = new Array(); \nvar foots = new Array(); \n"
      @partcount = 0
      @extra_foots = 0
      lastpart = nil
      @thedef.part_images.each { |part|
        # make part entry
        @parts_js += "parts[#{part.partnum - 1}] = '#{url_from_file(part.filename)}';\n"
        colfoot = url_from_file(part.colimg.colfootjpeg)
        if colfoot.nil?
          colfoot = '/assets/nofoot.png'
        end
        @parts_js += "foots[#{part.partnum - 1}] = '#{colfoot}';\n"
        @partcount += 1
        lastpart = part
      }
      index = lastpart.partnum
      ncol = lastpart.colimg
      4.times { |i| 
        ncol = col_from_col(ncol, NEXT) or break
        break if ncol.colfootjpeg.nil?
        @parts_js += "foots[#{index+i}] = '#{url_from_file(ncol.colfootjpeg)}';\n"
        @extra_foots += 1
      }
      
      # set up convenience vars
      case @thedef.status
        when 'NeedTyping'
          @action = t(:type_typing)
          @actno = AppConstants.type
        when 'NeedProof'
          @action = t(:type_proofing)
          @actno = AppConstants.proof
        when 'NeedFixup'
          @action = t(:type_fixups)
          @actno = AppConstants.fixup
        when 'Problem'
          @action = t(:type_problem)
          @actno = AppConstants.problem
        when 'NeedPublish'
          @action = t(:type_proofing)
          @actno = AppConstants.proof # a NeedPublish def would be here for reproofing
        else
          print "DBG: unknown status!\n"
          flash[:error] = t(:type_unknown_status, :status => @thedef.status)
          redirect_to :controller => 'user'
          return
      end
      @selects = ''
      ['arabic', 'greek', 'russian', 'extra'].each { |which|
        @selects += "<td><select id=\"#{which}\" name=\"#{which}\">"
        # @selects += "<td><select id=\"#{which}\" name=\"#{('type_'+which).intern.l}\">"
        ['none', 'todo', 'done'].each { |status|
          sel = (@thedef.read_attribute(which) == status) ? ' selected="selected">' : '>'
          @selects += '<option value="'+status+'"'+sel+t(('type_'+status).intern)+'</option>'
        }
        @selects += '</select></td>'
      }
      @page_title = @thedef.defhead
      render :action => 'edit' 
    end
  end
  def abandon
    @d = EbyDef.find_by_id(params[:id])
    do_abandon(@d)
    redirect_to :controller => 'user'
  end
  def processtype
    @d = EbyDef.find_by_id(params[:id])
    unless @d 
      flash[:error] = t(:type_defnotfound)
      redirect_to :controller => 'user'
      return
    end
    if params[:abandon]
      do_abandon(@d)
    elsif params[:commit]
      populate(@d)
      @d.save
      flash[:notice] = t(:type_saved_kept)
    elsif params[:save_and_done]
      populate(@d)
      newstat = ''
      defev = EbyDefEvent.new(:old_status => (@d.status == 'NeedProof' ? @d.status + (@d.proof_round_passed+1).to_s : @d.status), :thedef => @d, :who => session['user'].id)
      act = params[:act].to_i
      if act == AppConstants.type
        @d.status = 'NeedProof' # but override to fixup below if needed
        newstat = t(:type_await_proof_round, :round => '1')
        ['arabic', 'greek', 'russian', 'extra'].each { |which|
          if(@d.read_attribute(which) == 'todo')
            @d.status = 'NeedFixup'
            newstat = t(:type_await_fixups)
          end
        }
        @d.proof_round_passed = 0
      elsif act == AppConstants.proof
        @d.proof_round_passed += 1
        if @d.proof_round_passed >= LAST_PROOF_ROUND # >= because reproofing could take it beyond the limit
          newstat = t(:type_proofing_done)
          @d.status = 'NeedPublish'
        else
          newstat = t(:type_await_proof_round, :round => (@d.proof_round_passed+1).to_s)
        end
      elsif act == AppConstants.fixup
        still_todo = false
        ['arabic', 'greek', 'russian', 'extra'].each { |which|
          if(@d.read_attribute(which) == 'todo')
	    still_todo = true
          end
        }
	if(still_todo)
          newstat = t(:type_await_fixups)
        else
          @d.status = 'NeedProof'
          @d.proof_round_passed = 0 # start over in any case
          newstat = t(:type_await_proof_round, :round => '1')
	end
      elsif act == AppConstants.problem
        @d.status = params[:resolve_to]
        newstat = @d.status_label
      else
        throw Exception.new
      end
      @d.assignee = nil
      defev.new_status = (@d.status == 'NeedProof' ? @d.status + (@d.proof_round_passed+1).to_s : @d.status)
      defev.save
      @d.save!
      flash[:notice] = t(:type_saved_with_status, :status => newstat)
    elsif params[:problem]
      populate(@d)
      defev = EbyDefEvent.new(:old_status => @d.status, :new_status => 'Problem', :thedef => @d, :who => session['user'].id)
      defev.save
      @d.status = 'Problem'
      @d.assignee = nil
      @d.save
      flash[:notice] = t(:type_problematic)
    else
      flash[:error] = "not sure what I'm supposed to do with this submission.  Notify Asaf."
    end
    redirect_to :controller => 'user'
  end

  protected

  def check_the_roles
    return check_role('typist')
  end
  def is_assignee(thedef)
    if(thedef.assignee != session['user'])
      flash[:error] = t(:type_defnotyours)
      redirect_to :controller => 'user'
      return false
    else
      return true
    end
  end
  def populate(d)
    d.deftext = params[:deftext]
    d.defhead = params[:defhead]
    d.footnotes = params[:footnotes]
    d.arabic, d.greek, d.russian, d.extra = params[:arabic], params[:greek], params[:russian], params[:extra]
    #['arabic', 'greek', 'russian', 'extra'].each { |which|
    #  d.write_attribute(which, params[which])
    #}
    d.prob_desc = params[:prob_desc]
  end
  def call_assign_def_by_size(size, action)
    @thedef = EbyDef.assign_def_by_size(session['user'], size, action)
    if @thedef.nil?
      flash[:error] = t(:type_no_appropriate_def) 
      redirect_to :controller => 'user'
    else
      # edit
      redirect_to :action => 'edit', :id => @thedef.id
    end
  end
  def do_abandon(d)
    d.assignee = nil
    d.reject_count = 0 if d.reject_count.nil?
    d.reject_count += 1
    d.save
    flash[:notice] = t(:type_abandoned)
  end
end

