require 'eby_utils'
require 'csv'

include EbyUtils
namespace :sources do
  desc "go over all published defs looking for sources in sources markup"
  task :cull => :environment do
    # TODO: at some point, this should probably become going only over newly-published defs
    defs = EbyDef.where(status: 'Published')
    print "\nEbyDict - going over #{defs.count} published defs looking for sources in sources markup!\n"
    sources = []
    done = 0
    File.open('sources.csv', 'w') {|f|
      defs.each {|d|
        done += 1
        srcno = 1
        print "\r#{done} defs done..." if done % 10 == 0
        # find all matches for source markup
        matches = d.deftext.to_enum(:scan, /\[\[מקור:(.*?)\]\]/).map { Regexp.last_match }
        next if matches.nil?
        # export to CSV
        matches.each { |m|
          src = m.captures[0].strip
          srclink = link_for_source(src)
          puts "BIBLE: #{src} --> #{srclink}" unless srclink.empty?
          f.puts([d.id, srcno, src, srclink].to_csv)
          srcno += 1
        }
      }
    }
    puts "\nDone! Exported source references to ./sources.csv"
  end
end

private 


