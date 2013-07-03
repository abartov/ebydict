module EbyUtils
  # determine whether a volume of scans is _completely_ partitioned (i.e. all pages, all columns, all defs within columns)
  # this is crucial for generating the dictionary view, determining with certainty whether defs are first/last, etc.
  def is_volume_partitioned(vol)
    return false if EbyScanImage.where(status: 'NeedPartition').count > 0
    return false if EbyColumnImage.where("status <> 'Partitioned'").count > 0
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
   
    minpage = EbyScanImage.where(volume: 1).minimum(:firstpagenum)
    sc = EbyScanImage.where(firstpagenum: minpage, volume: vol).first # first scan of first volume
    c = sc.col_images.where(colnum: 1).first # first col
    return c.def_by_defno(0) # first def
 
  end
  def first_def
    return first_def_for_vol(1)
  end
end
