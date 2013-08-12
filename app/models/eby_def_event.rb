class EbyDefEventValidator < ActiveModel::Validator
  def validate(record)
    [record.old_status, record.new_status].each {|s| 
      if s.nil? or s.blank?
        record.errors[:base] << "the status fields cannot be empty"
      else
        unless /NeedProof\d+/.match(s)
          record.errors[:base] << "'#{s}' is not a valid status" unless %w( none Problem Partial GotOrphans NeedTyping NeedFixup NeedPublish Published ).include? s 
        end
      end
    }
  end
end
class EbyDefEvent < ActiveRecord::Base
  include ActiveModel::Validations
  attr_accessible :new_status, :old_status, :thedef, :who
  belongs_to :thedef, :class_name => 'EbyDef', :foreign_key => 'thedef'
  belongs_to :user, :class_name => 'EbyUser', :foreign_key => 'who'

  validates_with EbyDefEventValidator
end
