class EbyScanImage < ActiveRecord::Base
  attr_accessible :assignedto, :firstpagenum, :origjpeg, :partitioned_by, :secondpagenum, :smalljpeg, :status, :volume
  has_many :col_images, :class_name => 'EbyColumnImage', :foreign_key => 'eby_scan_image_id'
  belongs_to :assignee, :class_name => 'EbyUser', :foreign_key => 'assignedto'
  belongs_to :partitioner, :class_name => 'EbyUser', :foreign_key => 'partitioned_by'
  
  validates_uniqueness_of :origjpeg

  def columns
    return self.col_images.size
  end

end
