require 'RMagick'
include Magick

class ScanController < ApplicationController
  ZOOM_FACTOR = 0.25 # perhaps 0.33?
  COL_ZOOM_FACTOR = 0.33
  MARGIN = 10  # pixels of margin in each cut during partitioning
  PART_JPEGS_DIR = '/var/www/_ebydict/_ebyparts'
  DEV_PART_JPEGS_DIR = '/var/www/_ebydict/_ebyparts_dev'

  before_filter :check_the_roles

  def index    
    list
    render :action => 'list'
  end
  def list
    @scans = EbyScanImage.where(:status => 'NeedPartition', :assignedto => nil).page(params[:page])
  end
  def import
    if check_role('publisher')
      render :action => 'importform'
    end
  end
  def doimport
    @page_title = t(:scan_maintitle)
    # do the actual import
    if check_role('publisher')
      thedir = '/var/www/_ebydict/'+params[:path]
      @dio = ''
      Dir.glob(thedir+'/*.jpg').sort.each { |fname|
        # check for existing image
        if(EbyScanImage.find_by_origjpeg(fname))
          @dio += t(:scan_import_skipexist_html, :thefile => fname )
        else
          # create scanimage object
          newimg = EbyScanImage.new(:volume => params[:volume], :origjpeg => fname, :status => 'NeedPartition')
          newimg.save # save scanimage object
          @dio += t(:scan_import_created_html, :newid => newimg.id.to_s, :fname => fname)
        end
      }
      render :action => 'importdone'
    end
  end
  def abandon
    @sc = EbyScanImage.find_by_id(params[:id])
    if (not @sc.assignee.nil?) && @sc.assignee == session['user']
      flash[:notice] = t(:scan_abandoned)
      @sc.assignee = nil
      @sc.save
    else
      flash[:error] = t(:scan_notfound)
    end
    redirect_to :controller => 'user'
  end
  def abandon_col
    @col = EbyColumnImage.find_by_id(params[:id])
    if (not @col.assignee.nil?) && @col.assignee == session['user']
      flash[:notice] = t(:scan_abandoned)
      @col.assignee = nil
      @col.save
    else
      flash[:error] = t(:scan_notfound)
    end
    redirect_to :controller => 'user'
  end
  def list_cols
    @colimgs = EbyColumnImage.paginate_by_status 'NeedPartition', :conditions => 'assignedto is null', :page => params[:page]
  end
  def list_coldefs
    @coldefs = EbyColumnImage.paginate_by_status 'NeedDefPartition', :conditions => 'assignedto is null', :page => params[:page]
  end
  def part_def
    @page_title = "EbyDict: Separate Definitions" # TODO: localize
    unless params[:id].nil? # if id specified, get that
      @coldef = EbyColumnImage.find_by_id(params[:id])
      if (not @coldef.assignee.nil?) && (@coldef.assignee != session['user'])
        flash[:error] = t(:scan_notyours)
        redirect_to :action => 'list_coldefs'
        return
      end
    else # just grab an available one -- no point in letting the user pick one
      @coldef = EbyColumnImage.find_by_status('NeedDefPartition', :first, :conditions => "(assignedto is null) or (assignedto ='#{session['user'].id}')")
      if @coldef.nil?
        flash[:notice] = t(:scan_nomorecols)
        redirect_to :controller => 'user'
        return
      end
    end
    @coldef.assignee = session['user']
    @img = url_from_file(@coldef.coldefjpeg)
    @height, @width = get_dimensions_from_img(@coldef.coldefjpeg)
    @coldef.save
  end
  def part_col
    @page_title = "EbyDict: Partitioner" # TODO: localize
    unless params[:id].nil? # if id specified, get that
      @col = EbyColumnImage.find_by_id(params[:id])
      if (not @col.assignee.nil?) && (@col.assignee != session['user'])
        flash[:error] = t(:scan_notyours)
        redirect_to :action => 'list_cols'
        return
      end
    else # just grab an available one -- no point in letting the user pick one
      @col = EbyColumnImage.find_by_status('NeedPartition', :first, :conditions  => "(assignedto is null) or (assignedto ='#{session['user'].id}')")
      if @col.nil?
        flash[:notice] = t(:scan_nomorecols)
        redirect_to :controller => 'user'
        return
      end
    end
    @col.assignee = session['user']
    @colimg = url_from_file(@col.coljpeg)
    if @col.smalljpeg.nil?
      img =ImageList.new(@col.coljpeg)
      small = img.scale(COL_ZOOM_FACTOR)
      @col.smalljpeg =  fname_for_part(@col.coljpeg, 'small')
      small.write(@col.smalljpeg)
    end
    @colsmallimg = url_from_file(@col.smalljpeg)
    @height, @width = get_dimensions_from_img(@col.smalljpeg)
    @col.save
  end

  def partition
    @page_title = "EbyDict: Partitioner"
    unless params[:id].nil? # if id specified, get that
      @sc = EbyScanImage.find_by_id(params[:id])
      # check for assignment
      if (not @sc.assignee.nil?) && (@sc.assignee != session['user'])
        flash[:error] = t(:scan_notyours)
        redirect_to :action => 'list'
        return
      end
    else # just grab an available one -- no point in letting the user pick one
      @sc = EbyScanImage.find_by_status('NeedPartition', :first, :conditions => "(assignedto is null) or (assignedto ='#{session['user'].id}')")
      if @sc.nil?
        flash[:notice] = t(:scan_nomorescans)
        redirect_to :controller => 'user'
        return
      end
    end
    @sc.assignee = session['user']
    if @sc.smalljpeg.nil?
      # generate a scaled-down image for partitioning
      img = ImageList.new(@sc.origjpeg)
      small = img.scale(ZOOM_FACTOR) 
      @sc.smalljpeg = fname_for_part(@sc.origjpeg, 'small')
      small.write(@sc.smalljpeg)
    end
    # now display the image for partitioning
    @smallimg = url_from_file(@sc.smalljpeg) || "error!"
    @height, @width = get_dimensions_from_img(@sc.smalljpeg)
    @origimg = url_from_file(@sc.origjpeg) || "error!"
    @sc.save
    unless params[:prefill].nil?
      @prefilled_pagenums = params[:prefill] # prefill pagenums, if possible
    end
  end
  def docolpart
    @col = EbyColumnImage.find_by_id(params[:id])
    begin
      if params[:abandon]
        @col.assignee = nil
        @col.save
        flash[:notice] = t(:scan_abandoned)
        redirect_to :controller => 'user'
      else
        @msg = ''
        if params[:seps] == ''
          # no partition, i.e. no footnotes!
          @col.coldefjpeg = @col.coljpeg # same image, then
        else
          colimg = ImageList.new(@col.coljpeg)
          sep = params[:seps].to_i*(1/COL_ZOOM_FACTOR)
          coldefimg = colimg.crop(0,0, colimg.columns, sep + MARGIN)
          colfootimg = colimg.crop(0,sep - MARGIN, colimg.columns, colimg.rows - sep - MARGIN)
          @col.coldefjpeg = fname_for_part(@col.coljpeg, 'def_')
          @col.colfootjpeg = fname_for_part(@col.coljpeg, 'foot_')
          coldefimg.write(@col.coldefjpeg)
          colfootimg.write(@col.colfootjpeg)
        end
        @col.status = 'NeedDefPartition'
        @col.partitioner = session['user']
        @col.assignee = nil
        @col.save
        @msg += t(:scan_partedcol_html)
        flash[:notice] = @msg.html_safe
        if params[:save_and_next]
          # find a new available scanimg, and redirect back to partition
          @col = EbyColumnImage.find_by_status('NeedPartition', :first, :conditions => "(assignedto is null) or (assignedto ='#{session['user'].id}')")
          if @col.nil? # nothing available
            flash[:notice] = t(:scan_nomorecols)
            redirect_to :controller => 'user'
          else
            redirect_to :action => 'part_col', :id => @col.id
          end
        else
          redirect_to :controller => 'user'
        end
      end
    end
  end
  def dopartdef
    @col = EbyColumnImage.find_by_id(params[:id])
    begin
      if params[:abandon]
        @col.assignee = nil
        @col.save
        flash[:notice] = t(:scan_abandoned)
        redirect_to :controller => 'user'
      else
        last_def = nil
        colimg = ImageList.new(@col.coldefjpeg)
        seps = parse_seps(params[:seps]) 
        if seps.nil?
          # no partitions at all (i.e. the entire coldef is one definition (or continuation of one!)
          if params[:first_cont] == 'yes'
            last_def = add_to_prev_def(@col, @col.coldefjpeg, 0, false) # same image, since no cutting necessary!
          else
            last_def = makedef(@col, @col.coldefjpeg, 0, false)
          end
        else # got separations
          cur_bottom = colimg.rows - 1
          seps.each_index { |defno|
            defpartimg = colimg.crop(0, [0,seps[defno] - MARGIN].max, colimg.columns, cur_bottom - seps[defno] + 2*MARGIN)
            real_defno = seps.size - defno
            defpartimgname = fname_for_part(@col.coljpeg, 'def'+(real_defno).to_s+'_')
            defpartimg.write(defpartimgname)
            if real_defno == 1 && params[:first_cont] == 'yes'
              last_def = add_to_prev_def(@col, defpartimgname, real_defno - 1, (real_defno == seps.length ? false : true))
            else
              # an entry beginning on this column
              last_def = makedef(@col, defpartimgname, real_defno - 1, (real_defno == seps.length ? false : true)) # if there's a sep AFTER this one, this one's definitely a complete def!
            end
            cur_bottom = seps[defno]
          }
        end
        if params[:first_cont] == 'no' # see if previous column had a partial def waiting to know it's actually complete
          mark_prev_col_def_complete(@col)
        end
        if @col.status == 'NeedDefPartition' # only mark as partition if status wasn't changed (e.g. to GotOrphans by add_to_prev_def)
          @col.status = 'Partitioned'
        end 
        @col.defpartitioner = session['user']
        @col.assignee = nil
        @col.save
        collect_orphan_partdefs_for_col(@col, last_def) unless last_def.nil? # resolve partial defs continuing a def from THIS col!

        flash[:notice] = "Partitioned!" # TODO: improve message
        if params[:save_and_next]
          # find a new available colimg, and redirect back to partition
          @col = EbyColumnImage.find_by_status('NeedDefPartition', :first, :conditions => "(assignedto is null) or (assignedto ='#{session['user'].id}')")
          if @col.nil?
            flash[:notice] = t(:scan_nomorecols)
            redirect_to :controller => 'user'
          else
            redirect_to :action => 'part_def', :id => @col.id
          end
        else
          redirect_to :controller => 'user'
        end
      end
    end
  end
  def dopartition
    @sc = EbyScanImage.find_by_id(params[:id])
    
    # check submit type
    begin
      if params[:abandon]
        @sc.assignee = nil
        @sc.save
        flash[:notice] = "Returned this image to the pool"
        redirect_to :controller => 'user'
      elsif params[:pagenos].nil? or params[:pagenos].empty?
        @smallimg = url_from_file(@sc.smalljpeg) || "error!"
        @origimg = url_from_file(@sc.origjpeg) || "error!"

        flash[:error] = t(:scan_no_pagenums)
        render :action => 'partition'
      else
        # handle submitted partitioning
        params[:pagenos].match(/([0-9]*)-?([0-9]*)/)
        @sc.secondpagenum = $2 # nil is ok
        @sc.firstpagenum = $1
        
        @msg = ''
        origimg = ImageList.new(@sc.origjpeg)
        seps = parse_seps(params[:seps])
        if seps.nil?
          flash[:error] = t(:scan_no_cols)
          @smallimg = url_from_file(@sc.smalljpeg) || "error!"
          @origimg = url_from_file(@sc.origjpeg) || "error!"
          render :action => 'partition'
        else
          @msg += t(:scan_got_seps_html, :seps => (seps.length-1).to_s) + "<br/>"
          @seps = seps
          cur_right = origimg.columns - 1 # first partition begins at X=width-1 
          seps.each_index { |colno|
            realsep = (seps[colno] * (1 / ZOOM_FACTOR)).ceil # calculate real x coordinate according to factor
            # cut up orig jpeg
            colimg = origimg.crop([0,realsep - MARGIN].max, 0, cur_right - realsep + 2*MARGIN, origimg.rows)
            colimgname = fname_for_part(@sc.origjpeg, 'col'+(colno+1).to_s+'_')
            colimg.write(colimgname)
            # create appropriate number of column-image objects initialized to the new column jpegs
            newcol = EbyColumnImage.new(:eby_scan_image_id => @sc.id, :colnum => colno + 1, :coljpeg => colimgname,
              :volume => @sc.volume, :pagenum => (colno < 2) ? @sc.firstpagenum : @sc.secondpagenum, :status => 'NeedPartition')
#              :assignee => session['user']) # by default, assign the column partitioning to the same user
            # save the objects
            @msg += t(:scan_col_created, :colno => (colno+1).to_s, :fname => colimgname) + "<br/>"
            newcol.save
            # calculate next x coordinate
            cur_right = realsep
          }
          # change the scanimage's status to partitioned, noting the identity of the partitioner, and setting the scanimage to unassigned
          @sc.status = 'Partitioned'
          @sc.partitioner = session['user']
          @sc.assignee = nil
          @sc.save
          @msg += t(:scan_parted_scan_html, :fname => @sc.origjpeg, :vol => @sc.volume.to_s, :pages => "#{@sc.firstpagenum}-#{@sc.secondpagenum}")+"<br/>"
          flash[:notice] = @msg.html_safe
          if params[:save_and_next]
            # find a new available scanimg, and redirect back to partition
            newpagenum = @sc.firstpagenum.to_i+2
            @sc = EbyScanImage.find_by_status('NeedPartition', :first, :conditions => "(assignedto is null) or (assignedto ='#{session['user'].id}')")
            if @sc.nil?
              flash[:notice] = t(:scan_nomorescans)
              redirect_to :controller => 'user'
            else
              redirect_to :action => 'partition', :id => @sc.id, :prefill => "#{newpagenum}-#{newpagenum+1}"
            end
          else
            redirect_to :controller => 'user'
          end
        end
      end
    end
  end

  protected
  def get_dimensions_from_img(img)
    i = ImageList.new(img)
    return [i.rows, i.columns]
  end

  def check_the_roles
    return check_role('partitioner')
  end
  def fname_for_part(fname, prefix)
    last_slash = fname.rindex('/')
    filename = fname.slice(last_slash+1, fname.length - last_slash - 1)
    # TODO: optimize this to some app-level variable instead of a conditional here
    partdir = (Rails.env == 'production' ? PART_JPEGS_DIR : DEV_PART_JPEGS_DIR)   
    partname = partdir+'/'+prefix+filename
    return partname
  end
  def makedef(col, jpeg, defno, is_complete)
    newdef = EbyDef.new(:defhead => t(:type_unknown), :reject_count => 0, :proof_round_passed => 0,  :assignedto => nil, :status => ((is_complete or is_newdef_at_nextcol(col)) ? 'NeedTyping' : 'Partial'))
    newdef.save
    defev = EbyDefEvent.new(:old_status => 'none', :new_status => newdef.status, :thedef => newdef, :who => session['user'].id)
    defev.save
    newdefpart = EbyDefPartImage.new(:coldefimg_id => col.id, :filename => jpeg, :defno => defno, :partnum => 1, :thedef => newdef)
    newdefpart.save
    return newdef
  end 
  def parse_seps(s)
    return nil if(s == '')
    
    seps = s.split('|')
    seps.map! { |sep| sep.to_i }
    seps.push(0) # make the implicit leftmost partition explicit
    seps.sort!.reverse! 
    return seps
  end
  def is_newdef_at_nextcol(col)
    return false unless (nextcol = col_from_col(col, NEXT))
    return false unless nextcol.status == 'Partitioned'
    firstdef = EbyDefPartImage.find(:first, :conditions => "coldefimg_id = #{nextcol.id}", :order => 'defno asc')
    return (firstdef.partnum == 1) # if partnum == 0, then it's a continuation of this col's last def, we'll pick it up in the orphan collection
  end
  def mark_prev_col_def_complete(col)
    prevcol = col_from_col(col, PREV)
    return if prevcol.nil?
    last_defpart = EbyDefPartImage.find(:first, :conditions => "coldefimg_id = #{prevcol.id}", :order => 'defno desc') # find LAST defpart of prevcol
    return if last_defpart.nil?
    thedef = last_defpart.thedef
    if thedef.status == 'Partial'
      thedef.status = 'NeedTyping'
      thedef.save
      defev = EbyDefEvent.new(:old_status => 'Partial', :new_status => 'NeedTyping', :thedef => thedef, :who => session['user'].id)
      defev.save
    end
  end
  def add_to_prev_def(col, imgname,defno, is_complete)
    # find prev column (possibly in prev scanimg!
    prevcol = col_from_col(col, PREV) #or raise Exception.new
    if prevcol.nil? or (prevcol.status != 'Partitioned' and ((last_defpart = EbyDefPartImage.find(:first, :conditions => 'coldefimg_id = '+prevcol.id.to_s, :order => 'defno desc')).nil? or last_defpart.thedef.nil?)) # find LAST def of column
        # oh boy... this is the HARD case: we've got to stash this defpart as an orphan for now, and resolve it later!
        defpart = EbyDefPartImage.new(:filename => imgname, :thedef => nil, :coldefimg_id => col.id, :partnum => 0, :defno => 0, :is_last => (is_complete ? true : nil))
        defpart.save
        col.status = 'GotOrphans'
        col.save
        return nil
    else
      last_defpart = EbyDefPartImage.find(:first, :conditions => 'coldefimg_id = '+prevcol.id.to_s, :order => 'defno desc')
      if last_defpart.nil?
        raise Exception.new
      end
      # we're in luck -- the prev col may have orphans, but it DID manage to create a def at its bottom, so we can just latch onto it!
      thedef = last_defpart.thedef
      # create a new defpart with appropriate def seqno
      seqno = last_defpart.partnum+1
      defpart = EbyDefPartImage.new(:filename => imgname, :thedef => thedef, :coldefimg_id => col.id, :partnum => seqno, :defno => 0)
      defpart.save
      # save
      if (is_complete or is_newdef_at_nextcol(col)) 
        defev = EbyDefEvent.new(:old_status => thedef.status, :new_status => 'NeedTyping', :thedef => thedef, :who => session['user'].id)
        thedef.status = 'NeedTyping'
        defev.save
      end
      thedef.save
      return thedef
    end
  end
  def check_for_end_of_volume(col)
    # if all scans and all columns of the volume have been partitioned, we should mark the very last def NeedTyping rather than Partial
    if is_volume_partitioned(col.scan.volume)
      # for safety, look up the very last def manually rather than assume it's this exact column
      last_col = EbyColumnImage.find(:first, :order => "pagenum desc, colnum desc")
      last_def = last_col.def_part_images.order("defno desc").first.thedef # find last defpartimage for col and get its def
      last_def.status = "NeedTyping" 
      last_def.save! # whee!
    end
  end
  def collect_orphan_partdefs_for_col(col, lastdef)
    curcol = col
    curdef = lastdef
    begin 
      nextcol = col_from_col(curcol, NEXT)
      if nextcol.nil?
        check_for_end_of_volume(curcol)
        return
      end
      if(nextcol.status == 'GotOrphans')
        # orphan defparts have defno and partnum both 0
        orphan_part = EbyDefPartImage.find(:first, :conditions => "coldefimg_id = #{nextcol.id} and defno = 0 and partnum = 0")
        unless orphan_part.nil?
          orphan_part.thedef = curdef
          lastpart = EbyDefPartImage.find(:first, :conditions => "thedef = #{curdef.id}", :order => 'partnum desc') # find LAST part of def
          orphan_part.partnum = lastpart.partnum+1
          orphan_part.save # saved an orphan! :)
          nextcol.status = 'Partitioned' # whee!
          nextcol.save
          nextpart = EbyDefPartImage.find(:first, :conditions => "coldefimg_id = #{nextcol.id} and defno = 1") # look for another def on this col, to be able to mark THIS def NeedTyping!
          if (not nextpart.nil?) or is_newdef_at_nextcol(curcol)
            curdef.status = 'NeedTyping' # Whee!
            curdef.save
            orphan_part = nil # exit loop
	        elsif nextpart.nil?
            curcol = nextcol
            last_defpart = EbyDefPartImage.find(:first, :conditions => "coldefimg_id = #{curcol.id}", :order => 'defno desc') # find LAST def of next column
            curdef = last_defpart.thedef
          end
        end
      else
        orphan_part = nil
      end
    end until orphan_part.nil?
  end
end
