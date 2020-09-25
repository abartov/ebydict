class EbyDefPartImage < ApplicationRecord
  belongs_to :eby_def, :foreign_key => 'thedef', optional: true
  belongs_to :colimg, :class_name => 'EbyColumnImage', :foreign_key => 'coldefimg_id'

  validates :colimg, presence: true
  validates :defno, :partnum, numericality: true, allow_nil: true
  validates :is_last, inclusion: { in: [true, false] }, allow_nil: true
  has_one_attached :cloud_defpartjpeg

  def get_part_image
    return cloud_defpartjpeg.attached? ? cloud_defpartjpeg : colimg.get_coldefjpeg
  end
end
