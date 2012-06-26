class Dictentry < ActiveRecord::Base
	belongs_to :proofer1, :class_name => "User", :foreign_key => "proofer1_id"
	belongs_to :proofer2, :class_name => "User", :foreign_key => "proofer2_id"
	belongs_to :proofer3, :class_name => "User", :foreign_key => "proofer3_id"
	has_many :entryimages
end
