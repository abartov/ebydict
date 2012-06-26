class Scanimage < ActiveRecord::Base
  has_many :entryimages
  belongs_to :assignee, :class_name => 'EbyUser'
  belongs_to :partitioner, :class_name => 'EbyUser'
end
