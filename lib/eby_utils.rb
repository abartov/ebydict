module EbyUtils

  # constants
  BIBLE_BOOKS = { 'בראשית' => 1, 'שמות' => 2, 'ויקרא' => 3, 'במדבר' => 4, 'דברים' => 5, 'יהושע' => 6, 'שופטים' => 7, "שמואל א'" => 8, "שמואל ב'" => 9, "מלכים א'" => 10, "מלכים ב'" => 11, 'ישעיהו' => 12, 'ירמיהו' => 13, 'יחזקאל' => 14, 'הושע' => 15, 'יואל' => 16, 'עמוס' => 17, 'עובדיה' => 18, 'יונה' => 19, 'מיכה' => 20, 'נחום' => 21, 'חבקוק' => 22, 'צפניה' => 23, 'חגי' => 24, 'זכריה' => 25, 'מלאכי' => 26, 'תהילים' => 27, 'משלי' => 28, 'איוב' => 29, 'שיר השירים' => 30, 'רות' => 31, 'איכה' => 32, 'קהלת' => 33, 'אסתר' => 34, 'דניאל' => 35, 'עזרא' => 36, 'נחמיה' => 37, "דברי הימים א'" => 38, "דברי הימים ב'" => 39,"בראש'" => 1, "ברא'" => 1, "שמ'" => 2, "ויק'" => 3, "במד'" => 4, "דבר'" => 5, "יהו'" => 6,"שופ'" => 7, "ש\"א" => 8, "ש\"ב" => 9, "שמ\"א" => 8, "שמ\"ב" => 9, "מ\"א" => 10, "מ\"ב" => 11, "מל\"א" => 10, "מל\"ב" => 11, "יש'" => 12, "ישע'" => 12, "יר'" => 13, "ירמ'" => 13, "יח'" => 14, "יחז'" => 14, "יחזק'" => 14, "הוש'" => 15, "יו'" => 16, "עמ'" => 17, "עמו'" => 17, "עו'" => 18, "יונ'" => 19, "מי'" => 20, "נח'" => 21, "חב'" => 22, "צפ'" => 23, "חגי" => 24, "זכ'" => 25, "זכר'" => 25, "מלא'" => 26, "תה'" => 27, "משל'" => 28, "איוב" => 29, "שה\"ש" => 30, "רות" => 31, "איכ'" => 32, "קהל'" => 33, "אס'" => 34, "דנ'" => 35, "עז'" => 36, "נח'" => 37, "דה\"א" => 38, "דה\"ב" => 39}
  BIBLE_LINKS = { 
    1 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%91%D7%A8%D7%90%D7%A9%D7%99%D7%AA_",
    2 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A9%D7%9E%D7%95%D7%AA_",
    3 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%95%D7%99%D7%A7%D7%A8%D7%90_",
    4 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%91%D7%9E%D7%93%D7%91%D7%A8_",
    5 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%93%D7%91%D7%A8%D7%99%D7%9D_",
    6 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%99%D7%94%D7%95%D7%A9%D7%A2_",
    7 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A9%D7%95%D7%A4%D7%98%D7%99%D7%9D_",
    8 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A9%D7%9E%D7%95%D7%90%D7%9C_%D7%90_",
    9 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A9%D7%9E%D7%95%D7%90%D7%9C_%D7%91_",
    10 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%9E%D7%9C%D7%9B%D7%99%D7%9D_%D7%90_",
    11 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%9E%D7%9C%D7%9B%D7%99%D7%9D_%D7%91_",
    12 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%99%D7%A9%D7%A2%D7%99%D7%94%D7%95_",
    13 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%99%D7%A8%D7%9E%D7%99%D7%94%D7%95_",
    14 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%99%D7%97%D7%96%D7%A7%D7%90%D7%9C_",
    15 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%94%D7%95%D7%A9%D7%A2_",
    16 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%99%D7%95%D7%90%D7%9C_",
    17 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A2%D7%9E%D7%95%D7%A1_",
    18 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A2%D7%95%D7%91%D7%93%D7%99%D7%94_",
    19 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%99%D7%95%D7%A0%D7%94_",
    20 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%9E%D7%99%D7%9B%D7%94_",
    21 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A0%D7%97%D7%95%D7%9D_",
    22 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%97%D7%91%D7%A7%D7%95%D7%A7_",
    23 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A6%D7%A4%D7%A0%D7%99%D7%94_",
    24 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%97%D7%92%D7%99_",
    25 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%96%D7%9B%D7%A8%D7%99%D7%94_",
    26 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%9E%D7%9C%D7%90%D7%9B%D7%99_",
    27 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%AA%D7%94%D7%9C%D7%99%D7%9D_",
    28 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%9E%D7%A9%D7%9C%D7%99_",
    29 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%90%D7%99%D7%95%D7%91_",
    30 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A9%D7%99%D7%A8_%D7%94%D7%A9%D7%99%D7%A8%D7%99%D7%9D_",
    31 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A8%D7%95%D7%AA_",
    32 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%90%D7%99%D7%9B%D7%94_",
    33 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A7%D7%94%D7%9C%D7%AA_",
    34 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%90%D7%A1%D7%AA%D7%A8_",
    35 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%93%D7%A0%D7%99%D7%90%D7%9C_",
    36 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A2%D7%96%D7%A8%D7%90_",
    37 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%A0%D7%97%D7%9E%D7%99%D7%94_",
    38 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%93%D7%91%D7%A8%D7%99_%D7%94%D7%99%D7%9E%D7%99%D7%9D_%D7%90_",
    39 => "https://he.wikisource.org/wiki/%D7%A7%D7%98%D7%92%D7%95%D7%A8%D7%99%D7%94:%D7%93%D7%91%D7%A8%D7%99_%D7%94%D7%99%D7%9E%D7%99%D7%9D_%D7%91_"
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
    ret = BIBLE_BOOKS.keys.include?(parts[0])
    puts "parts[0]: #{parts[0]} --> #{ret}" # TODO: remove when calibrated
    return ret
  end
  def is_talmud(s)
    
  end
  def bible_link(s)
    parts = s.scan /\S+/
    puts parts
    link = BIBLE_LINKS[BIBLE_BOOKS[parts[0]]]
    if link.nil? or (parts.length < 3) # either an "Ibid." situation or some other unexpected issue
      #debugger
      File.open('missing_bible_links.txt','a') {|f| f.puts "No link found for: #{parts[0]} OR can't parse #{s}" } # TODO: remove when done calibrating
      return ''
    end
    verse = parts[2].sub('=','-') # some typed = for - in verse ranges
    if verse =~ /-/ # if a verse range, pick the beginning
      verse = verse[0..verse.index('-')-1]
    end
    link += parts[1] + '_' + verse
    return link
  end
  def gmara_link(s)
  
  end
  def link_for_source(s)
    ret = s
    return ret if s[0..1] == 'שם' # TODO: implement handling for ibid
    return "<a href=\"#{bible_link(s)}\">#{s}</a>" if is_bible(s)
    return "<a href=\"#{gmara_link(s)}\">#{s}</a>" if is_talmud(s)
    return ret # give up
  end
end
