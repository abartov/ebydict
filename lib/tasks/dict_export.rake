require 'eby_utils'
require 'sqlite3'

include EbyUtils
namespace :dict do
  desc "Export published definitions into a sqlite DB at public/dict.db"
  task :export  => :environment do
    maxvol = EbyScanImage.maximum(:volume)
    print "\nEbyDict - rendering volumes 1 to #{maxvol}!\n"
    @defs = []
    for vol in 1..maxvol do
      # collect all the defs _in the original order_ (therefore not through a query)
      print "Volume #{vol} -\n  building defs array... "
      @defs += collect_defs_for_vol(vol)
      # TODO: then render them to a static file through a view via render_to_string
      print "done!\nDone collecting defs from volume #{vol} of #{maxvol}.\n"
    end
    print "done!\n  Exporting all #{@defs.count} defs... "
    db = SQLite3::Database.new "#{Rails.root}/public/dict.db"
    db.results_as_hash = true
    db.execute("DROP TABLE IF EXISTS entries")
    db.execute("DROP TABLE IF EXISTS aliases")
    db.execute("CREATE TABLE entries (foreign_id integer, ordinal integer, defhead varchar(255), deftext text);")
    db.execute("CREATE TABLE aliases (foreign_id integer, alias varchar(255));")

    i = 1
    @defs.each do |d|
      unless d.nil?
        (rendered_body, rendered_footnotes) = d.render_body_as_html
        rendered_def = "<div class=\"deftext\">#{rendered_body}</div>"
        if rendered_footnotes =~ /\S/
          rendered_def += '<br/><hr width="30%" align="right"/><div class="defnotes">' + rendered_footnotes + '</div>'
        end
        db.execute("INSERT INTO entries VALUES (?, ?, ?, ?)", d.id, i, d.defhead, rendered_def)
        d.aliases.each do |al|
          db.execute("INSERT INTO aliases VALUES (?, ?)", d.id, al.alias)
        end
      else
        db.execute("INSERT INTO entries VALUES (?, ?, ?, ?)", nil, i, nil, nil)
      end
      i += 1
      print "#{i}... " if i % 200 == 0
    end
    puts " done!"
  end
end

private 

def collect_defs_for_vol(vol)
  ret = []
  unless is_volume_partitioned(vol)
    puts "skipping definitions from volume #{vol} as it's not fully partitioned yet"
    return ret
  end
  # index the volume if we haven't yet
  if last_def_for_vol(vol).ordinal.nil?
    print "Enumerating volume ##{vol}... (one-time process) -- "
    enumerate_vol(vol)
    print "done!\n"
  end
  ellipsis = false
  EbyDef.where(volume: vol).order('ordinal asc').each {|d|
    if d.published?
      ret << d
    else
      unpublished_def = d
      unpublished_def.defhead = nil
      ret << unpublished_def # add a nil member to the array, to signify any number of intervening headwords -- this may be output as ellipsis in HTML
    end
  }  
  return ret
end

