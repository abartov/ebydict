require 'rmagick'
include Magick
include EbyUtils
class ScanController < ApplicationController
  ZOOM_FACTOR = 0.25 # perhaps 0.33?
  COL_ZOOM_FACTOR = 0.33
  MARGIN = 15  # pixels of margin in each cut during partitioning
  MARGINX = 15  # pixels of margin in separating columns from each other
  PART_JPEGS_DIR = '/var/www/_ebydict/_ebyparts'
  DEV_PART_JPEGS_DIR = '/var/www/_ebydict/_ebyparts_dev'

  before_action :login_required
  before_action :check_the_roles

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
          newimg.save! # save scanimage object
          newimg.cloud_origjpeg.attach(io: File.open(fname), filename: fname[fname.rindex('/')+1..-1])
          newimg.cloud_origjpeg.save!
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
      @sc.save!
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
      @col.save!
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
      @coldef = EbyColumnImage.where("status = 'NeedDefPartition' and ((assignedto is null) or (assignedto ='#{session['user'].id}'))").first
      if @coldef.nil?
        flash[:notice] = t(:scan_nomorecols)
        redirect_to :controller => 'user'
        return
      end
    end
    @coldef.assignee = session['user']
    @coldef.save!
    coldefjpeg = @coldef.get_coldefjpeg
    @img = url_for(coldefjpeg)
    @filename = coldefjpeg.filename.to_s
    coldefjpeg.analyze unless coldefjpeg.analyzed? # necessary for height/width
    @height = coldefjpeg.metadata[:height]
    @width = coldefjpeg.metadata[:width]
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
      @col = EbyColumnImage.where("status = 'NeedPartition' and ((assignedto is null) or (assignedto ='#{session['user'].id}'))").first
      if @col.nil?
        flash[:notice] = t(:scan_nomorecols)
        redirect_to :controller => 'user'
        return
      end
    end
    @col.assignee = session['user']
    #@colimg = url_from_file(@col.coljpeg)
    @colimg = url_for(@col.cloud_coljpeg) || "error!"
    unless @col.cloud_smalljpeg.attached? && @col.cloud_smalljpeg.analyzed?
      body = HTTP.follow.get(@col.cloud_coljpeg.service_url).body
      begin
        temp_file = Tempfile.new('ebydict_col_'+@col.id.to_s, 'tmp/', binmode: true)
        temp_file.write(body)
        temp_file.flush
        tmpfilename = temp_file.path
        img = ImageList.new(tmpfilename)
        small = img.scale(COL_ZOOM_FACTOR)
        @col.cloud_smalljpeg.attach(io: StringIO.new(small.to_blob), filename: 'small'+@col.cloud_coljpeg.filename.to_s)
        @col.cloud_smalljpeg.save!
        # workaround bizarre ActiveStorage behavior
        sleep 5
        @col = EbyColumnImage.find(@col.id)
        @col.cloud_smalljpeg.analyze unless @col.cloud_smalljpeg.analyzed?
      ensure
        temp_file.close
      end
    end
    @colsmallimg = url_for(@col.cloud_smalljpeg)
    @height = @col.cloud_smalljpeg.metadata[:height]
    @width = @col.cloud_smalljpeg.metadata[:width]
    @col.save!
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
      @sc = EbyScanImage.where("status = 'NeedPartition' and ((assignedto is null) or (assignedto =#{session['user'].id}))").first
      if @sc.nil?
        flash[:notice] = t(:scan_nomorescans)
        redirect_to :controller => 'user'
        return
      end
    end
    @sc.assignee = session['user']
    unless @sc.cloud_smalljpeg.attached?
      # generate a scaled-down image for partitioning
      #response = Faraday.get(rails_blob_url(@sc.cloud_origjpeg, disposition: 'attachment'))
      logger.info 'getting blob...'
      body = HTTP.follow.get(@sc.cloud_origjpeg.service_url).body
      logger.info "got blob!"
      begin
        temp_file = Tempfile.new('ebydict_'+@sc.id.to_s, 'tmp/', binmode: true)
        temp_file.write(body)
        temp_file.flush
        logger.info "wrote blob!"
        tmpfilename = temp_file.path
        img = ImageList.new(tmpfilename)
        small = img.scale(ZOOM_FACTOR)
        logger.info "scaled blob!"
        @sc.cloud_smalljpeg.attach(io: StringIO.new(small.to_blob), filename: 'small' + @sc.cloud_origjpeg.filename.to_s)
        if(@sc.cloud_smalljpeg.attached?)
          logger.info "attached small blob!"
          @sc.cloud_smalljpeg.save!
          @sc.save!
          logger.info "saved blob!"
          logger.info "after save, attached? is #{@sc.cloud_smalljpeg.attached?}"
          # workaround bizarre ActiveStorage behavior where @sc.cloud_smalljpeg.attached? becomes *false* after this
          sleep 8
          @sc = EbyScanImage.find(@sc.id)
          @sc.cloud_smalljpeg.analyze unless @sc.cloud_smalljpeg.analyzed?
        else
          logger.info "failed to attach blob!"
        end
      rescue => exception
        logger.error "exception caught while creating cloud_smalljpeg! #{$!}\n#{exception.backtrace}"
      ensure
        temp_file.close
      end
    end
    # now display the image for partitioning
    i = 1
    logger.info "cloud_smalljpeg attached? #{@sc.cloud_smalljpeg.attached?}"
    begin
      analyzed = @sc.cloud_smalljpeg.analyzed?
    rescue
      nil
    end
    unless analyzed
      sleep 3 # we're going to need the height/width right away, so wait for the async job
      until i > 10 do
        begin
          analyzed = @sc.cloud_smalljpeg.analyzed?
        rescue
          nil
        end
        unless analyzed
          @sc.cloud_smalljpeg.analyze
          sleep 3 # we're going to need the height/width right away, so wait for the async job
          logger.info "waiting for smalljpeg analysis..."
        end
        i += 1
      end
    end
    @smallimg = url_for(@sc.cloud_smalljpeg) || "error!"
    @height = @sc.cloud_smalljpeg.metadata[:height]
    @width = @sc.cloud_smalljpeg.metadata[:width]
    # @height, @width = get_dimensions_from_img(@sc.smalljpeg)
    @origimg = url_for(@sc.cloud_origjpeg) || "error!"
    @sc.save!
    unless params[:prefill].nil?
      @prefilled_pagenums = params[:prefill] # prefill pagenums, if possible
    end
  end
  def docolpart
    @col = EbyColumnImage.find_by_id(params[:id])
    begin
      if params[:abandon]
        @col.assignee = nil
        @col.save!
        flash[:notice] = t(:scan_abandoned)
        redirect_to :controller => 'user'
      else
        @msg = ''
        unless params[:seps] == '' # no partition = no footnotes!
          body = HTTP.follow.get(@col.cloud_coljpeg.service_url).body
          begin
            temp_file = Tempfile.new('ebydict_col_'+@col.id.to_s, 'tmp/', binmode: true)
            temp_file.write(body)
            temp_file.flush
            logger.info "wrote blob!"
            tmpfilename = temp_file.path
            colimg = ImageList.new(tmpfilename)
            sep = params[:seps].to_i*(1/COL_ZOOM_FACTOR)
            coldefimg = colimg.crop(0,0, colimg.columns, sep + MARGIN)
            colfootimg = colimg.crop(0,sep - MARGIN, colimg.columns, colimg.rows - sep - MARGIN)
            @col.cloud_coldefjpeg.attach(io: StringIO.new(coldefimg.to_blob), filename: 'def_' + @col.cloud_coljpeg.filename.to_s)
            @col.cloud_colfootjpeg.attach(io: StringIO.new(colfootimg.to_blob), filename: 'foot_' + @col.cloud_coljpeg.filename.to_s)
          rescue
            logger.error "exception caught while creating cloud_coldefjpeg! #{$!}"
          ensure
            temp_file.close
          end
        end
        @col.status = 'NeedDefPartition'
        @col.partitioner = session['user']
        @col.assignee = nil
        @col.save!
        @msg += t(:scan_partedcol_html)
        flash[:notice] = @msg.html_safe
        if params[:save_and_next]
          # find a new available scanimg, and redirect back to partition
          @col = EbyColumnImage.where("status = 'NeedPartition' and ((assignedto is null) or (assignedto ='#{session['user'].id}'))").first
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
    success = true
    begin
      if params[:abandon]
        @col.assignee = nil
        @col.save!
        flash[:notice] = t(:scan_abandoned)
        redirect_to :controller => 'user'
      else
        last_def = nil
        seps = parse_seps(params[:seps]) 
        if seps.nil?
          # no partitions at all (i.e. the entire coldef is one definition (or continuation of one!)
          if params[:first_cont] == 'yes'
            last_def = add_to_prev_def(@col, nil, @col.get_coldefjpeg, 0, false) # same image, since no cutting necessary!
          else
            last_def = makedef(@col, nil, @col.get_coldefjpeg, 0, false)
          end
        else # got separations
          body = HTTP.follow.get(@col.get_coldefjpeg.service_url).body
          begin
            temp_file = Tempfile.new('ebydict_coldef'+@col.get_coldefjpeg.filename.to_s, 'tmp/', binmode: true)
            temp_file.write(body)
            temp_file.flush
            tmpfilename = temp_file.path
            colimg = ImageList.new(tmpfilename)
            cur_bottom = colimg.rows - 1
            seps.each_index { |defno|
              defpartimg = colimg.crop(0, [0,seps[defno] - MARGIN].max, colimg.columns, cur_bottom - seps[defno] + 2*MARGIN)
              real_defno = seps.size - defno

              defpartimgname = 'def'+(real_defno).to_s+'_'+@col.cloud_coljpeg.filename.to_s
              if real_defno == 1 && params[:first_cont] == 'yes'
                last_def = add_to_prev_def(@col, defpartimg, defpartimgname, real_defno - 1, (real_defno == seps.length ? false : true))
              else
                # an entry beginning on this column
                last_def = makedef(@col, defpartimg, defpartimgname, real_defno - 1, (real_defno == seps.length ? false : true)) # if there's a sep AFTER this one, this one's definitely a complete def!
              end
              cur_bottom = seps[defno]
            }
          rescue => exception
            logger.error "exception caught while creating coldefparts! #{$!}\n#{exception.backtrace}"
            success = false
          ensure
            temp_file.close
          end
        end
        if params[:first_cont] == 'no' # see if previous column had a partial def waiting to know it's actually complete
          mark_prev_col_def_complete(@col)
        end
        if success
          if @col.status == 'NeedDefPartition' # only mark as partition if status wasn't changed (e.g. to GotOrphans by add_to_prev_def)
            @col.status = 'Partitioned'
          end 
          @col.defpartitioner = session['user']
          @col.assignee = nil
          @col.save!
          flash[:notice] = "Partitioned!" # TODO: improve message
        else
          flash[:error] = $!
        end
        collect_orphan_partdefs_for_col(@col, last_def) unless last_def.nil? # resolve partial defs continuing a def from THIS col!

        if params[:save_and_next]
          # find a new available colimg, and redirect back to partition
          @col = EbyColumnImage.where("status = 'NeedDefPartition' and ((assignedto is null) or (assignedto ='#{session['user'].id}'))").first
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
        @sc.save!
        flash[:notice] = "Returned this image to the pool"
        redirect_to :controller => 'user'
      else
        @smallimg = url_for(@sc.cloud_smalljpeg) || "error!"
        @height = @sc.cloud_smalljpeg.metadata[:height]
        @width = @sc.cloud_smalljpeg.metadata[:width]
        # @height, @width = get_dimensions_from_img(@sc.smalljpeg)
        @origimg = url_for(@sc.cloud_origjpeg) || "error!"
        if params[:pagenos].nil? or params[:pagenos].empty?
          flash[:error] = t(:scan_no_pagenums)
          render :action => 'partition'
        else
          # handle submitted partitioning
          seps = parse_seps(params[:seps])
          if seps.nil?
            flash[:error] = t(:scan_no_cols)
            render :action => 'partition'
          else
            params[:pagenos].match(/([0-9]*)-?([0-9]*)/)
            @sc.secondpagenum = $2 # nil is ok
            @sc.firstpagenum = $1
            @msg = ''
            #faraday = Faraday.new(url: rails_blob_url(@sc.cloud_origjpeg, disposition: 'attachment')) do |faraday|
            #  faraday.use FaradayMiddleware::FollowRedirects
            #  faraday.adapter Faraday.default_adapter
            #end
            body = HTTP.follow.get(@sc.cloud_origjpeg.service_url).body
            #response = faraday.get
            begin
              temp_file = Tempfile.new('ebydict_'+@sc.id.to_s, 'tmp/', binmode: true)
              temp_file.write(body)
              temp_file.flush
              tmpfilename = temp_file.path
              origimg = ImageList.new(tmpfilename)
              @msg += t(:scan_got_seps_html, :seps => (seps.length-1).to_s) + "<br/>"
              @seps = seps
              cur_right = origimg.columns - 1 # first partition begins at X=width-1 
              seps.each_index do |colno|
                margin_x = params[:double_margin] == 'on' ? MARGINX*2 : MARGINX
                realsep = (seps[colno] * (1 / ZOOM_FACTOR)).ceil # calculate real x coordinate according to factor
                # cut up orig jpeg
                colimg = origimg.crop([0,realsep - margin_x].max, 0, cur_right - realsep + 2*margin_x, origimg.rows)
                # create appropriate number of column-image objects initialized to the new column jpegs
                newcol = EbyColumnImage.new(:eby_scan_image_id => @sc.id, :colnum => colno + 1,
                  :volume => @sc.volume, :pagenum => (colno < 2) ? @sc.firstpagenum : @sc.secondpagenum, :status => 'NeedPartition')
                # save the objects
                colimgname = @sc.cloud_origjpeg.filename.to_s
                @msg += t(:scan_col_created, :colno => (colno+1).to_s, :fname => colimgname) + "<br/>"
                newcol.cloud_coljpeg.attach(io: StringIO.new(colimg.to_blob), filename: "col#{colno+1}_#{colimgname}")
                newcol.cloud_coljpeg.save!
                # calculate next x coordinate
                cur_right = realsep
              end
              # change the scanimage's status to partitioned, noting the identity of the partitioner, and setting the scanimage to unassigned
              @sc.status = 'Partitioned'
              @sc.partitioner = session['user']
              @sc.assignee = nil
              @sc.save!
              @msg += t(:scan_parted_scan_html, :fname => @sc.cloud_origjpeg.filename.to_s, :vol => @sc.volume.to_s, :pages => "#{@sc.firstpagenum}-#{@sc.secondpagenum}")+"<br/>"
              flash[:notice] = @msg.html_safe
            ensure
              temp_file.close
            end

            if params[:save_and_next]
              # find a new available scanimg, and redirect back to partition
              newpagenum = @sc.secondpagenum.nil? ? @sc.firstpagenum.to_i+1 : @sc.firstpagenum.to_i+2
              @sc = EbyScanImage.where("status = 'NeedPartition' and ((assignedto is null) or (assignedto = #{session['user'].id}))").first
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
    firstdef = EbyDefPartImage.where(coldefimg_id: nextcol.id).order('defno asc').first
    return (firstdef.partnum == 1) # if partnum == 0, then it's a continuation of this col's last def, we'll pick it up in the orphan collection
  end
  def mark_prev_col_def_complete(col)
    prevcol = col_from_col(col, PREV)
    return if prevcol.nil?
    last_defpart = EbyDefPartImage.where(coldefimg_id: prevcol.id).order('defno desc').first # find LAST defpart of prevcol
    return if last_defpart.nil?
    thedef = last_defpart.eby_def
    if thedef.status == 'Partial'
      thedef.status = 'NeedTyping'
      thedef.save!
      defev = EbyDefEvent.new(:old_status => 'Partial', :new_status => 'NeedTyping', :thedef => thedef.id, :who => session['user'].id)
      defev.save!
    end
  end
  def add_to_prev_def(col, blob, imgname, defno, is_complete)
    # find prev column (possibly in prev scanimg!
    prevcol = col_from_col(col, PREV) #or raise Exception.new
    if prevcol.nil? or (prevcol.status != 'Partitioned' and ((last_defpart = EbyDefPartImage.where(coldefimg_id: prevcol.id).order('defno desc').first).nil? or last_defpart.eby_def.nil?)) # find LAST def of column
        # oh boy... this is the HARD case: we've got to stash this defpart as an orphan for now, and resolve it later!
        defpart = EbyDefPartImage.new(thedef: nil, coldefimg_id: col.id, partnum: 0, defno: 0, is_last: (is_complete ? true : nil))
        defpart.save!
        unless blob.nil?
          defpart.cloud_defpartjpeg.attach(io: StringIO.new(blob.to_blob), filename: imgname)
          if defpart.cloud_defpartjpeg.attached?
            defpart.cloud_defpartjpeg.save!
          end
        end # if no blob was given, EbyDefPartImage.get_part_image will return the attached jpeg from the column
        col.status = 'GotOrphans'
        col.save!
        return nil
    else
      last_defpart = EbyDefPartImage.where(coldefimg_id: prevcol.id).order('defno desc').first
      if last_defpart.nil?
        raise Exception.new
      end
      # we're in luck -- the prev col may have orphans, but it DID manage to create a def at its bottom, so we can just latch onto it!
      thedef = last_defpart.eby_def
      if thedef.nil?
        raise Exception.new
      end
      # create a new defpart with appropriate def seqno
      seqno = last_defpart.partnum+1
      defpart = EbyDefPartImage.new(thedef: thedef.id, coldefimg_id: col.id, partnum: seqno, defno: 0)
      defpart.save!
      unless blob.nil?
        defpart.cloud_defpartjpeg.attach(io: StringIO.new(blob.to_blob), filename: imgname)
        if defpart.cloud_defpartjpeg.attached?
          defpart.cloud_defpartjpeg.save!
        end
      end # if no blob was given, EbyDefPartImage.get_part_image will return the attached jpeg from the column
      # save
      if (is_complete or is_newdef_at_nextcol(col))
        defev = EbyDefEvent.new(:old_status => thedef.status, :new_status => 'NeedTyping', :thedef => thedef.id, :who => session['user'].id)
        thedef.status = 'NeedTyping'
        defev.save!
      end
      thedef.save!
      return thedef
    end
  end
  def check_for_end_of_volume(col)
    # if all scans and all columns of the volume have been partitioned, we should mark the very last def NeedTyping rather than Partial
    if is_volume_partitioned(col.scan.volume)
      # for safety, look up the very last def manually rather than assume it's this exact column
      last_col = EbyColumnImage.order('pagenum desc, colnum desc').first
      last_def = last_col.def_part_images.order("defno desc").first.eby_def # find last defpartimage for col and get its def
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
        orphan_part = EbyDefPartImage.where(coldefimg_id: nextcol.id, defno: 0, partnum: 0).first
        unless orphan_part.nil?
          orphan_part.eby_def = curdef
          lastpart = EbyDefPartImage.where(thedef: curdef.id).order('partnum desc').first # find LAST part of def
          orphan_part.partnum = lastpart.partnum+1
          orphan_part.save! # saved an orphan! :)
          nextcol.status = 'Partitioned' # whee!
          nextcol.save!
          nextpart = EbyDefPartImage.where(coldefimg_id: nextcol.id, defno: 1).first # look for another def on this col, to be able to mark THIS def NeedTyping!
          if (not nextpart.nil?) or is_newdef_at_nextcol(curcol)
            curdef.status = 'NeedTyping' # Whee!
            curdef.save!
            orphan_part = nil # exit loop
	        elsif nextpart.nil?
            curcol = nextcol
            last_defpart = EbyDefPartImage.where(coldefimg_id: curcol.id).order('defno desc').first # find LAST def of next column
            curdef = last_defpart.eby_def
          end
        end
      else
        orphan_part = nil
      end
    end until orphan_part.nil?
  end
end
