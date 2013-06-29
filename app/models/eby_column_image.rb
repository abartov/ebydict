class EbyColumnImage < ActiveRecord::Base
  attr_accessible :assignedto, :coldefjpeg, :colfootjpeg, :coljpeg, :colnum, :defpartitioner_id, :eby_scan_image_id, :pagenum, :partitioned_by, :smalljpeg, :status, :volume

  belongs_to :scan, :class_name => 'EbyScanImage', :foreign_key => 'eby_scan_image_id'
  #has_many :EbyDefPartImage
  has_many :def_part_images, :class_name => 'EbyDefPartImage', :foreign_key => 'coldefimg_id'
  belongs_to :assignee, :class_name => 'EbyUser', :foreign_key => 'assignedto'
  belongs_to :partitioner, :class_name => 'EbyUser', :foreign_key => 'partitioned_by'
  belongs_to :defpartitioner, :class_name => 'EbyUser', :foreign_key => 'defpartitioner_id'
  belongs_to :coldefimg, :class_name => 'EbyColumnImage', :foreign_key => 'coldefimg_id' # TODO: this looks bogus; verify and remove
 
  validates_uniqueness_of :coljpeg
  def def_part_by_defno(defno)
    def_part_images.each {|dp|
      if dp.defno == defno
        return dp
      end
    }
    return nil
  end
  def last_def_part
    ret = def_part_images.first
    def_part_images.each {|dp|
      ret = dp if dp.defno > ret.defno
    }
    return ret
  end
  def def_by_defno(defno)
    d = def_part_images.where(defno: defno).first
    return nil if d.nil?
    return d.thedef
  end
end
