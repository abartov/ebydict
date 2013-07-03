require 'eby_utils'
include EbyUtils
namespace :dict do
  desc "Render the entire set of published definitions of the dictionary into a static HTML file"
  task :render  => :environment do
    maxvol = EbyScanImage.maximum(:volume)
    print "\nEbyDict - rendering volumes 1 to #{maxvol}!\n"
    for vol in 1..maxvol do
      # collect all the published defs _in the original order_ (therefore not through a query)
      pubdefs = collect_published_defs_for_vol(vol)
      # TODO: then render them to a static file through a view via render_to_string
      print "DEBUG: Pubdefs = \n #{pubdefs.to_s}\n"
    end
  end
end

private 

def collect_published_defs_for_vol(vol)
  ret = []
  d = first_def_for_vol(vol)
  ellipsis = false
  until d.nil? do
    if d.published?
      ret << d
      ellipsis = false
    else
      unless ellipsis
        ellipsis = true
        ret << nil # add a nil member to the array, to signify any number of intervening headwords -- this may be output as ellipsis in HTML
      end
    end
    d = d.successor_def # iterate
  end
  return ret
end

