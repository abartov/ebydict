module EbyUtils

  # constants
  BIBLE_BOOKS = ['בראשית', 'שמות', 'ויקרא', 'במדבר', 'דברים', 'יהושע', 'שופטים', "שמואל א'", "שמואל ב'", "מלכים א'", "מלכים ב'", 'ישעיהו', 'ירמיהו', 'יחזקאל', 'הושע', 'יואל', 'עמוס', 'עובדיה', 'יונה', 'מיכה', 'נחום', 'חבקוק', 'צפניה', 'חגי', 'זכריה', 'מלאכי', 'תהילים', 'משלי', 'איוב', 'שיר השירים', 'רות', 'איכה', 'קהלת', 'אסתר', 'דניאל', 'עזרא', 'נחמיה', "דברי הימים א'", "דברי הימים ב'","בר'","שמ'", "ויק'", "במד'", "דבר'", "יהו'","שופ'", "ש\"א", "ש\"ב", "שמ\"א", "שמ\"ב", "מ\"א", "מ\"ב", "מל\"א", "מל\"ב", "יש'", "יר'", "יח'", "הוש'", "יו'", "עמ'", "עו'", "יונ'", "מי'", "נח'", "חב'", "צפ'", "זכ'", "מלא'", "תה'", "משל'", "שה\"ש", "איכ'", "קה'", "אס'", "דנ'", "עז'", "נח'", "דה\"א", "דה\"ב"]
  BIBLE_LINKS = { 
    "בראש'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%91%D7%A8%D7%90%D7%A9%D7%99%D7%AA_",
    "שמ'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A9%D7%9E%D7%95%D7%AA_",
    "ויק'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%95%D7%99%D7%A7%D7%A8%D7%90_",
    "במד'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%91%D7%9E%D7%93%D7%91%D7%A8_",
    "דבר'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%93%D7%91%D7%A8%D7%99%D7%9D_",
    "יהו'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%99%D7%94%D7%95%D7%A9%D7%A2_",
    "שופ'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A9%D7%95%D7%A4%D7%98%D7%99%D7%9D_",
    "שמ\"א" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A9%D7%9E%D7%95%D7%90%D7%9C_%D7%90_",
    "שמ\"ב" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A9%D7%9E%D7%95%D7%90%D7%9C_%D7%91_",
    "מל\"א" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%9E%D7%9C%D7%9B%D7%99%D7%9D_%D7%90_",
    "מל\"ב" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%9E%D7%9C%D7%9B%D7%99%D7%9D_%D7%91_",
    "ישע'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%99%D7%A9%D7%A2%D7%99%D7%94%D7%95_",
    "ירמ'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%99%D7%A8%D7%9E%D7%99%D7%94%D7%95_",
    "יחז'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%99%D7%97%D7%96%D7%A7%D7%90%D7%9C_",
    "הוש'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%94%D7%95%D7%A9%D7%A2_",
    "יוא'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%99%D7%95%D7%90%D7%9C_",
    "עמ'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A2%D7%9E%D7%95%D7%A1_",
    "עו'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A2%D7%95%D7%91%D7%93%D7%99%D7%94_",
    "יונ'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%99%D7%95%D7%A0%D7%94_",
    "מי'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%9E%D7%99%D7%9B%D7%94_",
    "נח'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A0%D7%97%D7%95%D7%9D_",
    "חבק'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%97%D7%91%D7%A7%D7%95%D7%A7_",
    "צפ'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A6%D7%A4%D7%A0%D7%99%D7%94_",
    "חגי" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%97%D7%92%D7%99_",
    "זכ'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%96%D7%9B%D7%A8%D7%99%D7%94_",
    "מלא'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%9E%D7%9C%D7%90%D7%9B%D7%99_",
    "תה'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%AA%D7%94%D7%9C%D7%99%D7%9D_",
    "משל'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%9E%D7%A9%D7%9C%D7%99_",
    "איוב" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%90%D7%99%D7%95%D7%91_",
    "שה\"ש" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A9%D7%99%D7%A8_%D7%94%D7%A9%D7%99%D7%A8%D7%99%D7%9D_",
    "רות" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A8%D7%95%D7%AA_",
    "איכ'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%90%D7%99%D7%9B%D7%94_",
    "קהל'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A7%D7%94%D7%9C%D7%AA_",
    "אס'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%90%D7%A1%D7%AA%D7%A8_",
    "דנ'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%93%D7%A0%D7%99%D7%90%D7%9C_",
    "עז'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A2%D7%96%D7%A8%D7%90_",
    "נח'" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A0%D7%97%D7%9E%D7%99%D7%94_",
    "דה\"א" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%93%D7%91%D7%A8%D7%99_%D7%94%D7%99%D7%9E%D7%99%D7%9D_%D7%90_",
    "דה\"ב" => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%93%D7%91%D7%A8%D7%99_%D7%94%D7%99%D7%9E%D7%99%D7%9D_%D7%91_"
  }

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
  def is_bible(s)
    parts = s.scan /\S+/
    ret = BIBLE_BOOKS.include?(parts[0])
    puts "parts[0]: #{parts[0]} --> #{ret}" # TODO: remove when calibrated
    return ret
  end
  def is_gmara(s)
  
  end
  def bible_link(s)
    parts = s.scan /\S+/
    puts parts
    link = BIBLE_LINKS[parts[0]]
    if link.nil?
      File.open('missing_bible_links.txt','a') {|f| f.puts "No link found for: #{parts[0]}" } # TODO: remove when done calibrating
      return ''
    end
    verse = parts[2] 
    if verse =~ /-/ # if a verse range, pick the beginning
      verse = verse[0..verse.index('-')-1]
    end
    link += parts[1] + '_' + verse
    return link
  end
  def gmara_link(s)
  
  end
  def link_for_source(s)
    ret = ''
    return ret if s[0..1] == 'שם' # TODO: implement handling for ibid
    return bible_link(s) if is_bible(s)
    return gmara_link(s) if is_gmara(s)
    return ret # give up
  end
end
