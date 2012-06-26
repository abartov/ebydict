class EbyDefEvent < ActiveRecord::Base
  attr_accessible :new_status, :old_status, :thedef, :who
  belongs_to :thedef, :class_name => 'EbyDef', :foreign_key => 'thedef'
  belongs_to :user, :class_name => 'EbyUser', :foreign_key => 'who'

end
