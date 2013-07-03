require 'eby_utils'
include EbyUtils
namespace :dict do
  desc "Render the entire set of published definitions of the dictionary into a static HTML file"
  task :render  => :environment do
    maxvol = EbyScanImage.maximum(:volume)
    print "\nEbyDict - rendering volumes 1 to #{maxvol}!\n"
    for vol in 1..maxvol do
      # collect all the published defs _in the original order_ (therefore not through a query)
      print "Volume #{vol} -\n  building defs array... "
      @defs = collect_published_defs_for_vol(vol)
      # TODO: then render them to a static file through a view via render_to_string
      print "done!\n  Rendering... "
      template = File.read("#{Rails.root}/app/views/definition/list.html.erb")
      renderer = ERB.new(template)
      result = renderer.result(binding) # pass the current context, to give access to @defs
      print "done!\n  Writing file... "
      File.open("full_dict.html","wb") {|f| f.write(result) }
      print "done!\nDone rendering volume #{vol} of #{maxvol}.\n"
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

