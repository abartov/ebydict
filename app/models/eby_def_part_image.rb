class EbyDefPartImage < ApplicationRecord
  belongs_to :eby_def, :foreign_key => 'thedef'
  belongs_to :colimg, :class_name => 'EbyColumnImage', :foreign_key => 'coldefimg_id'

  validates :colimg, presence: true
  validates :defno, :partnum, numericality: true, allow_nil: true
  validates :is_last, inclusion: { in: [true, false] }, allow_nil: true
end
