class AddVolumeToEbyDef < ActiveRecord::Migration[4.2]
  def change
    add_column :eby_defs, :volume, :integer
    print "adding volume number to all existing defs... "
    EbyDef.all.each {|d|
      d.volume = d.part_images.first.colimg.volume
      d.save
    }
    print "done!\n"
  end
end
