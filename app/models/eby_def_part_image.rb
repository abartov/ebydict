class EbyDefPartImage < ActiveRecord::Base
  attr_accessible :coldefimg_id, :defno, :filename, :is_last, :partnum, :thedef
  belongs_to :thedef, :class_name => 'EbyDef', :foreign_key => 'thedef'
  belongs_to :colimg, :class_name => 'EbyColumnImage', :foreign_key => 'coldefimg_id'

  validates :colimg, presence: true
  validates :defno, :partnum, numericality: true, allow_nil: true
  validates :is_last, inclusion: { in: [true, false] }, allow_nil: true
end
