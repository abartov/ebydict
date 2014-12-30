class EbyMarker < ActiveRecord::Base
  attr_accessible :marker_y, :partnum # :def_id, :user_id

  belongs_to :thedef, class_name: 'EbyDef', foreign_key: 'def_id'
  belongs_to :user, class_name: 'EbyUser', foreign_key: 'user_id'
end
