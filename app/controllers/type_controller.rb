class TypeController < ApplicationController
  include EbyUtils
  before_action :login_required
  before_action :check_the_roles

  def index
    list
    render :action => 'list'
  end
  def list # TODO: what does this mean for this controller?
    #edit
  end
  def set_marker
    @d = EbyDef.find(params[:id])
    if @d.marker.nil?
      @d.marker = EbyMarker.new(user_id: session['user'].id, thedef: @d)
    end
    @d.marker.partnum = params[:partnum]
    @d.marker.marker_y = params[:marker_y]
    @d.marker.footpart = params[:footpart]
    @d.marker.footmarker = params[:footmarker]
    @d.marker.save!
    @d.save!
    head :ok
  end
  def get_fixup
    unless(check_role('fixer'))
      flash[:error] = t(:type_notfixer)
      redirect_to :controller => 'user'
    else
      call_assign_def_by_size(params[:defsize], Rails.configuration.constants['fixup'], nil)
    end
  end
  def get_proof
    round = params[:round].nil? ? session['user'].max_proof_level : params[:round].to_i
    if not check_role('proofer')
      flash[:error] = t(:type_notproofer)
      redirect_to :controller => 'user'
    elsif(session['user'].max_proof_level < round)
      flash[:error] = t(:type_round_not_allowed)
      redirect_to :controller => 'user'
    else
      call_assign_def_by_size(params[:defsize], Rails.configuration.constants['proof'], round)
    end
  end
  def get_def
    unless(check_role('typist'))
      flash[:error] = t(:type_nottypist)
      redirect_to :controller => 'user'
    else
      call_assign_def_by_size(params[:defsize], Rails.configuration.constants['type'], nil)
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
      return
    else
      # prepare defpart images for client-side JS to handle
      @parts_js = "var parts = new Array(); \nvar foots = new Array(); \n"
      @partcount = 0
      @extra_foots = 0
      lastpart = nil
      @thedef.part_images.each { |part|
        # make part entry
        @parts_js += "parts[#{part.partnum - 1}] = '#{url_for(part.get_part_image)}';\n"
        if part.colimg.cloud_colfootjpeg.attached?
          colfoot = url_for(part.colimg.cloud_colfootjpeg)
        else
          colfoot = '/assets/nofoot.png'
        end
        @parts_js += "foots[#{part.partnum - 1}] = '#{colfoot}';\n"
        @partcount += 1
        lastpart = part
      }
      index = lastpart.partnum
      ncol = lastpart.colimg
      6.times { |i|
        ncol = col_from_col(ncol, NEXT) or break
        break unless ncol.cloud_colfootjpeg.attached?
        @parts_js += "foots[#{index+i}] = '#{url_for(ncol.cloud_colfootjpeg)}';\n"
        @extra_foots += 1
      }

      # set up convenience vars
      case @thedef.status
        when 'NeedTyping'
          @action = t(:type_typing)
          @actno = Rails.configuration.constants['type']
        when 'NeedProof'
          @action = t(:type_proofing)
          @actno = Rails.configuration.constants['proof']
        when 'NeedFixup'
          @action = t(:type_fixups)
          @actno = Rails.configuration.constants['fixup']
        when 'Problem'
          @action = t(:type_problem_action)
          @actno = Rails.configuration.constants['problem']
        when 'NeedPublish'
          @action = t(:type_proofing)
          @actno = Rails.configuration.constants['proof'] # a NeedPublish def would be here for reproofing
        when 'Published'
          @action = t(:type_proofing)
          @actno = Rails.configuration.constants['proof']
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
      @marker_ajax_url = url_for(action: :set_marker, id: @thedef.id)
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
    elsif params[:commit] or params[:save]
      populate(@d)
      @d.save!
      flash[:notice] = t(:type_saved_kept)
    elsif params[:save_and_done]
      populate(@d)
      @newstat = ''
      defev = EbyDefEvent.new(:old_status => (@d.status == 'NeedProof' ? @d.status + (@d.proof_round_passed+1).to_s : @d.status), :thedef => @d.id, :who => session['user'].id)
      act = params[:act].to_i
      if act == Rails.configuration.constants['type']
        @d.status = 'NeedProof' # but override to fixup below if needed
        @newstat = t(:type_await_proof_round, :round => '1')
        ['arabic', 'greek', 'russian', 'extra'].each { |which|
          if(@d.read_attribute(which) == 'todo')
            @d.status = 'NeedFixup'
            @newstat = t(:type_await_fixups)
          end
        }
        @d.proof_round_passed = 0
      elsif act == Rails.configuration.constants['proof']
        increase_proof
      elsif act == Rails.configuration.constants['fixup']
        still_todo = false
        ['arabic', 'greek', 'russian', 'extra'].each { |which|
          if(@d.read_attribute(which) == 'todo')
            still_todo = true
          end
        }
        if(still_todo)
          @newstat = t(:type_await_fixups)
        else
          @d.status = 'NeedProof'
          @d.proof_round_passed = 0 # start over in any case
          @newstat = t(:type_await_proof_round, :round => '1')
        end
      elsif act == Rails.configuration.constants['problem']
        @d.status = params[:resolve_to]
        increase_proof if params['increase_proof'] == '1'
        @newstat = @d.status_label
      else
        throw Exception.new
      end
      @d.assignee = nil
      defev.new_status = (@d.status == 'NeedProof' ? @d.status + (@d.proof_round_passed+1).to_s : @d.status)
      defev.save
      @d.marker.delete unless @d.marker.nil? # delete place marker when def done
      @d.save!
      flash[:notice] = t(:type_saved_with_status, :status => @newstat)
    elsif params[:problem]
      populate(@d)
      defev = EbyDefEvent.new(:old_status => @d.status, :new_status => 'Problem', :thedef => @d.id, :who => session['user'].id)
      defev.save
      @d.status = 'Problem'
      @d.assignee = nil
      @d.marker.delete unless @d.marker.nil? # delete place marker when def done
      @d.save
      flash[:notice] = t(:type_problematic)
    else
      flash[:error] = "not sure what I'm supposed to do with this submission.  Notify Asaf."
    end
    unless params[:save]
      redirect_to :controller => 'user'
    else # if user just wanted to save and continue, render the edit view right back again
      @thedef = @d
      edit
    end
  end

  protected

  def check_the_roles
    return check_role('typist')
  end
  def increase_proof
    @d.proof_round_passed += 1
    if @d.proof_round_passed >= LAST_PROOF_ROUND # >= because reproofing could take it beyond the limit
      @newstat = t(:type_proofing_done)
      @d.status = 'NeedPublish'
    else
      @newstat = t(:type_await_proof_round, :round => (@d.proof_round_passed+1).to_s)
    end
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
    d.footnotes = '' if d.footnotes =~ /#{t(:type_footnotes)}/ # remove the placeholder text that TinyMCE causes us to stick in the textarea # TODO: upgrade to TinyMCE 4.x and use proper HTML5 placeholders to avoid this kluge
    d.arabic, d.greek, d.russian, d.extra = params[:arabic], params[:greek], params[:russian], params[:extra]
    d.prob_desc = params[:prob_desc]
  end
  def call_assign_def_by_size(size, action, round)
    @thedef = EbyDef.assign_def_by_size(session['user'], size, action, round)
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
    d.marker.delete unless d.marker.nil? # forget place marker when abandoning a def
    d.save
    flash[:notice] = t(:type_abandoned)
  end
end
