module EbyUtils

  # constants
  BIBLE_BOOKS = { 'בראשית' => 1, 'שמות' => 2, 'ויקרא' => 3, 'במדבר' => 4, 'דברים' => 5, 'יהושע' => 6, 'שופטים' => 7, "שמואל א'" => 8, "שמואל ב'" => 9, "מלכים א'" => 10, "מלכים ב'" => 11, 'ישעיהו' => 12, 'ירמיהו' => 13, 'יחזקאל' => 14, 'הושע' => 15, 'יואל' => 16, 'עמוס' => 17, 'עובדיה' => 18, 'יונה' => 19, 'מיכה' => 20, 'נחום' => 21, 'חבקוק' => 22, 'צפניה' => 23, 'חגי' => 24, 'זכריה' => 25, 'מלאכי' => 26, 'תהילים' => 27, "תהלים" => 27, 'משלי' => 28, 'איוב' => 29, 'שיר השירים' => 30, 'רות' => 31, 'איכה' => 32, 'קהלת' => 33, 'אסתר' => 34, "אסת'" => 34, 'דניאל' => 35, 'עזרא' => 36, 'נחמיה' => 37, "דברי הימים א'" => 38, "דברי הימים ב'" => 39,"בראש'" => 1, "ברא'" => 1, "שמ'" => 2, "שמו'" => 2, "ויק'" => 3, "ויקר'" => 3, "במד'" => 4, "במדב'" => 4, "דבר'" => 5, "יהו'" => 6, "יהוש'" => 6, "שופ'" => 7, "שופט'" => 7, "ש\"א" => 8, "ש\"ב" => 9, "שמ\"א" => 8, "שמ\"ב" => 9, "מ\"א" => 10, "מ\"ב" => 11, "מל\"א" => 10, "מל\"ב" => 11, "יש'" => 12, "ישע'" => 12, "ישעי'" => 12, "יר'" => 13, "ירמ'" => 13, "יח'" => 14, "יחז'" => 14, "יחזק'" => 14, "הוש'" => 15, "יו'" => 16, "עמ'" => 17, "עמו'" => 17, "עו'" => 18, "יונ'" => 19, "מי'" => 20, "מיכ'" => 20, "נח'" => 21, "חב'" => 22, "חבק'" => 22, "צפ'" => 23, "צפנ'" => 23, "חגי" => 24, "זכ'" => 25, "זכר'" => 25, "מלא'" => 26, "תה'" => 27, "תהל'" => 27, "תהלי'" => 27, "משל'" => 28, "איו'" => 29, "שה\"ש" => 30, "רות" => 31, "איכ'" => 32, "קהל'" => 33, "אס'" => 34, "דנ'" => 35, "דני'" => 35, "עז'" => 36, "נחמי'" => 37, "נח'" => 37, "נחמ'" => 37, "דה\"א" => 38, "דה\"ב" => 39, "דהי\"א" => 38, "דהי\"ב" => 39}
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
      prevscan = EbyScanImage.where('firstpagenum = '+page.to_s+' or secondpagenum = '+page.to_s).first
      return nil if prevscan.nil?
      retcol = EbyColumnImage.where(eby_scan_image_id: prevscan.id).order('colnum desc').first # find LAST column of scan
    elsif retcolnum > col.scan.columns # look for next scanimg
      page = col.pagenum+1
      nextscan = EbyScanImage.where('firstpagenum = '+page.to_s+' or secondpagenum = '+page.to_s).first
      return nil if nextscan.nil?
      retcol = EbyColumnImage.where(eby_scan_image_id: nextscan.id).order('colnum asc').first # find FIRST column of scan
    else # simple case - same scan, different col
      retcol = EbyColumnImage.where(eby_scan_image_id: col.scan.id, colnum: retcolnum).first
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
    return c.def_part_images.where(defno: c.def_part_images.maximum(:defno)).first.eby_def
  end
  def first_def
    return first_def_for_vol(1)
  end
  # write ordinal numbers for definitions in the volume, for faster dictionary-view render
  def enumerate_vol(vol)
    raise VolumeNotCompletelyPartitioned.new unless is_volume_partitioned(vol)
    d = first_def_for_vol(vol)
    last_predecessor = d
    counter = 1
    until d.nil? or d.volume != vol do
      d.ordinal = counter
      d.save
      counter += 1
      last_predecessor = d
      d = d.successor_def
    end
    if last_predecessor != last_def_for_vol(vol)
      puts "Incomplete enumeration detected: last successfully enumerated def was ID: #{last_predecessor.id}, #{last_predecessor.defhead}"
    end
    # Pair each orphaned def (missed by chain traversal because it shares a
    # (column, defno) with another def) with the enumerated sibling at that position.
    pairs = EbyDef.where(volume: vol, ordinal: nil).filter_map do |orphan|
      if orphan.part_images.empty?
        puts "WARNING: def ID=#{orphan.id} (#{orphan.defhead}) has nil ordinal but no part_images; cannot determine (column, defno) position"
        next
      end
      first_part = orphan.part_images.first
      sibling = first_part.colimg.def_part_images
                  .where(defno: first_part.defno)
                  .where.not(thedef: orphan.id)
                  .filter_map(&:eby_def)
                  .find { |s| s.ordinal.present? }
      unless sibling
        puts "WARNING: def ID=#{orphan.id} (#{orphan.defhead}) has nil ordinal and no enumerated sibling at its position"
        next
      end
      { orphan: orphan, sibling: sibling, sibling_ordinal: sibling.ordinal }
    end
    EbyDef.transaction do
      # Pass 1: process from highest sibling ordinal to lowest so each shift only displaces
      # positions above the current insertion point, leaving lower insert points intact.
      pairs.sort_by { |p| -p[:sibling_ordinal] }.each do |pair|
        orphan, sibling, n = pair.values_at(:orphan, :sibling, :sibling_ordinal)
        # Compare in dictionary order: consonants (strip nikkud), then full defhead, then ID
        cmp = orphan.defhead.strip_nikkud <=> sibling.defhead.strip_nikkud
        cmp = orphan.defhead <=> sibling.defhead if cmp == 0
        cmp = orphan.id     <=> sibling.id       if cmp == 0
        if cmp < 0
          EbyDef.where(volume: vol).where('ordinal >= ?', n).where.not(id: orphan.id).update_all('ordinal = ordinal + 1')
          orphan.update!(ordinal: n)
          puts "Note: def ID=#{orphan.id} (#{orphan.defhead}) inserted before sibling ID=#{sibling.id} at ordinal #{n}"
        else
          EbyDef.where(volume: vol).where('ordinal > ?', n).where.not(id: orphan.id).update_all('ordinal = ordinal + 1')
          orphan.update!(ordinal: n + 1)
          puts "Note: def ID=#{orphan.id} (#{orphan.defhead}) inserted after sibling ID=#{sibling.id} at ordinal #{n + 1}"
        end
      end

      # Pass 2: handle defs skipped because a multi-column spanning def jumped over their
      # column, or because a spanning continuation landed at defno>0 leaving earlier
      # defnos unvisited.  Process in physical reading order so each orphan's predecessor
      # is already placed when we get to it.
      isolated = EbyDef.where(volume: vol, ordinal: nil)
                       .includes(part_images: :colimg)
                       .select { |orphan| orphan.part_images.any? }
                       .sort_by { |orphan|
                         p = orphan.part_images.first
                         c = p.colimg
                         [c.pagenum, c.colnum, p.defno, orphan.id]
                       }
      isolated.each do |orphan|
        first_part = orphan.part_images.first
        col = first_part.colimg
        defno = first_part.defno

        # Single query: nearest predecessor in the same column that has an ordinal.
        # Re-query eby_defs via join to pick up ordinals freshly assigned in this loop.
        pred_part = EbyDefPartImage
                      .joins("INNER JOIN eby_defs ON eby_defs.id = eby_def_part_images.thedef AND eby_defs.ordinal IS NOT NULL")
                      .where(coldefimg_id: col.id)
                      .where('eby_def_part_images.defno < ?', defno)
                      .order('eby_def_part_images.defno DESC')
                      .first

        if pred_part
          ref_ordinal = EbyDef.find(pred_part.thedef).ordinal
          EbyDef.where(volume: vol).where('ordinal > ?', ref_ordinal).where.not(id: orphan.id).update_all('ordinal = ordinal + 1')
          orphan.update!(ordinal: ref_ordinal + 1)
          puts "Note: def ID=#{orphan.id} (#{orphan.defhead}) inserted after def ID=#{pred_part.thedef} at ordinal #{orphan.ordinal}"
        else
          # No predecessor — single query for nearest successor with an ordinal
          succ_part = EbyDefPartImage
                        .joins("INNER JOIN eby_defs ON eby_defs.id = eby_def_part_images.thedef AND eby_defs.ordinal IS NOT NULL")
                        .where(coldefimg_id: col.id)
                        .where('eby_def_part_images.defno > ?', defno)
                        .order('eby_def_part_images.defno ASC')
                        .first
          if succ_part
            ref_def = EbyDef.find(succ_part.thedef)
            ref_ordinal = ref_def.ordinal
            if succ_part.partnum > 1
              # Successor is a continuation from a previous column; that def's logical
              # position is determined by where it started, not here.  Place the orphan
              # (which begins in this column) after the continuation.
              EbyDef.where(volume: vol).where('ordinal > ?', ref_ordinal).where.not(id: orphan.id).update_all('ordinal = ordinal + 1')
              orphan.update!(ordinal: ref_ordinal + 1)
              puts "Note: def ID=#{orphan.id} (#{orphan.defhead}) inserted after continuation ID=#{ref_def.id} at ordinal #{orphan.ordinal}"
            else
              # Successor starts here; orphan belongs before it
              EbyDef.where(volume: vol).where('ordinal >= ?', ref_ordinal).where.not(id: orphan.id).update_all('ordinal = ordinal + 1')
              orphan.update!(ordinal: ref_ordinal)
              puts "Note: def ID=#{orphan.id} (#{orphan.defhead}) inserted before def ID=#{ref_def.id} at ordinal #{orphan.ordinal}"
            end
          else
            puts "WARNING: def ID=#{orphan.id} (#{orphan.defhead}) could not be placed - no anchor found in column #{col.id}"
          end
        end
      end
    end
  end
  def html_entities_coder
    @html_entities_coder ||= HTMLEntities.new
  end
  def is_bible(s)
    parts = s.scan /\S+/
    ret = BIBLE_BOOKS.keys.include?(parts[0])
    #puts "parts[0]: #{parts[0]} --> #{ret}" # TODO: remove when calibrated
    return ret
  end
  def is_talmud(s)
    return false # TODO: implement    
  end
  def bible_link(s)
    parts = s.scan /\S+/
    # puts parts # DBG
    link = BIBLE_LINKS[BIBLE_BOOKS[parts[0]]]
    if link.nil? or (parts.length < 3) # either an "Ibid." situation or some other unexpected issue
      File.open('missing_bible_links.txt','a') {|f| f.puts "No link found for: #{parts[0]} OR can't parse #{s}" } # TODO: remove when done calibrating
      return ''
    end
    verse = parts[2].sub('=','-') # some typed = for - in verse ranges
    if verse =~ /-/ # if a verse range, pick the beginning
      verse = verse[0..verse.index('-')-1]
    end
    link += parts[1].sub('יה','טו').sub('יו','טז') + '_' + verse
    return link
  end
  def gmara_link(s)
  
  end
  def link_for_source(s)
    ret = s.strip
    ret = ret[1..-2] if ret[0]==')' && ret[-1]=='('
    return ret if s[0..1] == 'שם' # TODO: implement handling for ibid
    return "<a href=\"#{bible_link(s)}\">#{s}</a>" if is_bible(s)
    return "<a href=\"#{gmara_link(s)}\">#{s}</a>" if is_talmud(s)
    return ret # give up
  end
  def link_for_redirect(s)
    ret = s
    d = EbyDef.find_by_defhead(s) # look for exact match # TODO: some fallback?
    return ret unless d
    return ret unless d.status == 'Published'
    ret = "<a href=\"#{d.permalink}\">#{s}</a>"
    return ret
  end

  def cleanup_parens(s)
    while s =~ /\[\[מקור:\s*\((.*?)\)\]\]/
      puts "found [[מקור: \(#{$1}\)]] ---> ([[מקור: #{$1}]])"
      s.sub!(/\[\[מקור:\s*\((.*?)\)\]\]/,"([[מקור: #{$1}]])")
    end
    return s
  end

  # used in partitioning (scan controller)
  def makedef(col, blob, jpeg, defno, is_complete)
    newdef = EbyDef.new(:defhead => t(:type_unknown), :reject_count => 0, :proof_round_passed => 0,  :assignedto => nil, :status => ((is_complete or is_newdef_at_nextcol(col)) ? 'NeedTyping' : 'Partial'), :volume => col.volume)
    newdef.save!
    defev = EbyDefEvent.new(:old_status => 'none', :new_status => newdef.status, :thedef => newdef.id, :who => session['user'].id)
    defev.save!
    newdefpart = EbyDefPartImage.new(:coldefimg_id => col.id, :defno => defno, :partnum => 1, :thedef => newdef.id)
    newdefpart.save!
    unless blob.nil?
      newdefpart.cloud_defpartjpeg.attach(io: StringIO.new(blob.to_blob), filename: jpeg)
      if newdefpart.cloud_defpartjpeg.attached?
        newdefpart.cloud_defpartjpeg.save!
      end
    end # if no blob was given, EbyDefPartImage.get_part_image will return the attached jpeg from the column
    return newdef
  end
end
