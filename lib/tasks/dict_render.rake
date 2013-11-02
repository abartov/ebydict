require 'eby_utils'
include EbyUtils
namespace :dict do
  desc "Render the entire set of published definitions of the dictionary into a static HTML file"
  task :render  => :environment do
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
    print "done!\n  Rendering all defs... "
    template = File.read("#{Rails.root}/app/views/definition/list.html.erb")
    renderer = ERB.new(template)
    result += renderer.result(binding) # pass the current context, to give access to @defs
    print "done!\n  Writing file... "
    File.open("#{Rails.root}/public/full_dict.html","wb") {|f| f.write(result) }
  end
end

private 

def collect_published_defs_for_vol(vol)
  ret = []
  return ret unless is_volume_partitioned(vol)
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

