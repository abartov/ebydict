class EbyScanImage < ActiveRecord::Base
  # attr_accessible :assignedto, :firstpagenum, :origjpeg, :partitioned_by, :secondpagenum, :smalljpeg, :status, :volume
  has_many :col_images, :class_name => 'EbyColumnImage', :foreign_key => 'eby_scan_image_id'
  belongs_to :assignee, :class_name => 'EbyUser', :foreign_key => 'assignedto', optional: true
  belongs_to :partitioner, :class_name => 'EbyUser', :foreign_key => 'partitioned_by'

  validates :origjpeg, presence: true, uniqueness: true
  validates :volume, presence: true, numericality: true
  validates :firstpagenum, :secondpagenum, numericality: true, allow_nil: true
  validates :smalljpeg, uniqueness: true, allow_nil: true
  validates :status, inclusion: { in: %w(NeedPartition Partitioned) }

  def columns
    return self.col_images.size
  end

end
