class EbyColumnImage < ApplicationRecord

  belongs_to :scan, :class_name => 'EbyScanImage', :foreign_key => 'eby_scan_image_id'
  #has_many :EbyDefPartImage
  has_many :def_part_images, :class_name => 'EbyDefPartImage', :foreign_key => 'coldefimg_id'
  belongs_to :assignee, :class_name => 'EbyUser', :foreign_key => 'assignedto', optional: true
  belongs_to :partitioner, :class_name => 'EbyUser', :foreign_key => 'partitioned_by', optional: true
  belongs_to :defpartitioner, :class_name => 'EbyUser', :foreign_key => 'defpartitioner_id', optional: true
  
#  validates :cloud_coljpeg, presence: true
#  validates :coldefjpeg, :colfootjpeg, :smalljpeg, allow_nil: true
  validates :pagenum, :colnum, presence: true, numericality: true
  validates :status, presence: true, inclusion: { in: %w(NeedPartition NeedDefPartition Partitioned GotOrphans) }
  validates :scan, presence: true # mandatory association
  has_one_attached :cloud_coljpeg
  has_one_attached :cloud_smalljpeg
  has_one_attached :cloud_coldefjpeg
  has_one_attached :cloud_colfootjpeg
   
  def def_part_by_defno(defno)
    return def_part_images.where(defno: defno).first
  end
  # NB: this is the last def part _in the column_, not the last part of any particular def
  def first_def_part
    # er, this seems like a silly method -- this would be definition be zero, wouldn't it?  TODO: verify and remove
    return def_part_images.minimum(:defno)
  end
  def last_def_part
    return def_part_images.maximum(:defno)
  end
  def get_coldefjpeg # cloud_coldefjpeg would be unattached where there was no partitioning because no footnotes
    cloud_coldefjpeg.attached? ? cloud_coldefjpeg : cloud_coljpeg
  end
  def def_by_defno(defno)
    d = def_part_by_defno(defno)
    return nil if d.nil?
    return d.eby_def
  end
end
