module EbyUtils
  # determine whether a volume of scans is _completely_ partitioned (i.e. all pages, all columns, all defs within columns)
  # this is crucial for generating the dictionary view, determining with certainty whether defs are first/last, etc.
  def is_volume_partitioned(vol)
    return false if EbyScanImage.where(volume: vol).count == 0 # make sure the volume exists...
    return false if EbyScanImage.where(status: 'NeedPartition', volume: vol).count > 0
    return false if EbyColumnImage.where("status <> 'Partitioned' and volume = #{vol}").count > 0
    return true
  end

  NEXT = 1
  PREV = -1

  def col_from_col(col, delta) # retrieves next or prev column image, based on given colimg object and delta (NEXT, PREV)
    return nil unless delta == NEXT || delta == PREV
    retcolnum = col.colnum + delta
    if retcolnum < 1 # look for prev scanimg
      page = col.pagenum-1
      prevscan = EbyScanImage.find(:first, :conditions => 'firstpagenum = '+page.to_s+' or secondpagenum = '+page.to_s)
      return nil if prevscan.nil?
      retcol = EbyColumnImage.find(:first, :conditions => 'eby_scan_image_id = '+prevscan.id.to_s, :order => 'colnum desc') # find LAST column of scan
    elsif retcolnum > col.scan.columns # look for next scanimg
      page = col.pagenum+1
      nextscan = EbyScanImage.find(:first, :conditions => 'firstpagenum = '+page.to_s+' or secondpagenum = '+page.to_s)
      return nil if nextscan.nil?
      retcol = EbyColumnImage.find(:first, :conditions => 'eby_scan_image_id = '+nextscan.id.to_s, :order => 'colnum asc') # find FIRST column of scan
    else # simple case - same scan, different col
      retcol = EbyColumnImage.find(:first, :conditions => "eby_scan_image_id = "+col.scan.id.to_s+" and colnum = #{retcolnum}")
    end
    return retcol
  end
  def first_def_for_vol(vol)
    raise VolumeNotCompletelyPartitioned.new unless is_volume_partitioned(vol)
   
    minpage = EbyScanImage.where(volume: vol).minimum(:firstpagenum)
    sc = EbyScanImage.where(firstpagenum: minpage, volume: vol).first # first scan of first volume
    c = sc.col_images.where(colnum: 1).first # first col
    return c.def_by_defno(0) # first def
 
  end
  def last_def_for_vol(vol)
    raise VolumeNotCompletelyPartitioned.new unless is_volume_partitioned(vol)
    
    maxfirstpage = EbyScanImage.where(volume: vol).maximum(:firstpagenum)
    maxsecondpage = EbyScanImage.where(volume: vol).maximum(:secondpagenum)
    if maxsecondpage > maxfirstpage 
      maxpage = EbyScanImage.where(secondpagenum: maxsecondpage, volume: vol).first
    else
      maxpage = EbyScanImage.where(firstpagenum: maxfirstpage, volume: vol).first
    end
    c = maxpage.col_images.where(colnum: maxpage.col_images.maximum(:colnum)).first
    return c.def_part_images.last.thedef
  end
  def first_def
    return first_def_for_vol(1)
  end
  # write ordinal numbers for definitions in the volume, for faster dictionary-view render
  def enumerate_vol(vol)
    raise VolumeNotCompletelyPartitioned.new unless is_volume_partitioned(vol)
    d = first_def_for_vol(vol)
    counter = 1
    until d.nil? do
      d.ordinal = counter
      d.save
      counter += 1
      d = d.successor_def
    end
  end
  def html_entities_coder
    @html_entities_coder ||= HTMLEntities.new
  end
end
