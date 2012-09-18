class EbyDef < ActiveRecord::Base
  attr_accessible :arabic, :assignedto, :defhead, :deftext, :extra, :footnotes, :greek, :proof_round_passed, :russian, :status
  belongs_to :assignee, :class_name => 'EbyUser', :foreign_key => 'assignedto'
  has_many :part_images, :class_name => 'EbyDefPartImage', :foreign_key => 'thedef', :order => 'partnum asc'
  has_many :events, :class_name => 'EbyDefEvent', :foreign_key => 'thedef'

  # validations
  validates_inclusion_of :status, :in => %w( Problem Partial GotOrphans NeedTyping NeedProof NeedFixup NeedPublish Published )
  validates_associated :assignee

  def self.assign_def_by_size(to_user, size, action)
    sizecond = ""
    wherecond = "" # what to add to the WHERE clause
    case action
      when AppConstants.type 
        status = "NeedTyping"
        action = "type"
      when AppConstants.proof 
        status = "NeedProof"
        action = "proof"
        wherecond = " and proof_round_passed < "+to_user.max_proof_level.to_s+" and #{to_user.id} not in (select who from eby_def_events where thedef = eby_defs.id and new_status LIKE 'NeedProof%' ORDER BY proof_round_passed )" # prefer to assign highest allowed proofing round, as there are presumably fewer proofers available to work at each successive proof level
      when AppConstants.fixup 
        status = "NeedFixup"
        action = "fix-up"
        wherecond = " and (false "
        # iterate over possible fixups, against user's defined capabilities
        wherecond += " or eby_defs.arabic = 'todo' " if(to_user.does_arabic)
        wherecond += " or eby_defs.greek = 'todo' " if(to_user.does_greek)
        wherecond += " or eby_defs.russian = 'todo' " if(to_user.does_russian)
        wherecond += " or eby_defs.extra = 'todo' " if(to_user.does_extra)
        # finally, close the where condition
        wherecond += " )"
      else
        throw Exception.new
    end
    case size
      when 'medium' 
        sizecond = "= 2"
      when 'large' 
        sizecond = "> 3"
      else # assume 'small'
        sizecond = " = 1"
    end

    rset = EbyDef.find_by_sql("select eby_defs.*, count(dp.id) from eby_defs inner join eby_def_part_images dp on eby_defs.id = dp.thedef where assignedto is null and status = '#{status}' #{wherecond} group by eby_defs.id having count(dp.id) " + sizecond + " limit 1")  #
    if rset.nil? or rset[0].nil?
      return nil
    else
      thedef = rset[0]
      thedef.assignedto = to_user.id
      thedef.save
      return thedef
    end
  end
end
