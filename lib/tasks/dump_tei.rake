require 'eby_utils'
include EbyUtils

TEI_HEADER = <<END
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<?xml-stylesheet type="text/xsl" href="tei-dictionary.xsl"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0">
   <teiHeader>
      <fileDesc>
         <titleStmt>
            <title>Eliezer Ben-Yehuda''s Hebrew Dictionary</title>
         </titleStmt>
         <publicationStmt>
            <p>In-progress dump, August 2019, prepared by Asaf Bartov, editor@benyehuda.org</p>
         </publicationStmt>
         <sourceDesc>
            <p>Transcribed from the 1980 facsimile edition of the dictionary, by Project Ben-Yehuda volunteers. See ebydict.benyehuda.org </p>
         </sourceDesc>
      </fileDesc>
   </teiHeader>
   <text>
     <body>
END
TEI_FOOTER = '</body></text></TEI>'

namespace :dict do
  desc "Dump the entire set of published definitions of the dictionary into a TEI file"
  task :dump_tei  => :environment do
    maxvol = EbyScanImage.maximum(:volume)
    print "\nEbyDict - rendering volumes 1 to #{maxvol}!\n"
    @defs = []
    for vol in 1..maxvol do
      # collect all the published defs _in the original order_ (therefore not through a query)
      print "Volume #{vol} -\n  building defs array... "
      @defs += collect_published_defs_for_vol(vol)
      # TODO: then render them to a static file through a view via render_to_string
      print "done!\nDone collecting defs from volume #{vol} of #{maxvol}.\n"
    end
    print "done!\n  Rendering all defs into TEI... "
    result = TEI_HEADER
    @defs.each {|d| if d.nil?
                      result += "\n <!-- missing definitions -->"
                    else
                      result += "\n#{d.render_tei}"
                    end
               }
    result += "\n"+TEI_FOOTER
    print "done!\n  Writing file... "
    File.open("#{Rails.root}/public/full_dict.tei.xml","wb") {|f| f.write(result) }
  end
end

private 

def collect_published_defs_for_vol(vol)
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
      ellipsis = false
    else
      unless ellipsis
        ellipsis = true
        ret << nil # add a nil member to the array, to signify any number of intervening headwords -- this may be output as ellipsis in HTML
      end
    end
  }  
  return ret
end

