class EbyDef < ActiveRecord::Base
  attr_accessible :arabic, :assignedto, :defhead, :deftext, :extra, :footnotes, :greek, :proof_round_passed, :russian, :status
  belongs_to :assignee, :class_name => 'EbyUser', :foreign_key => 'assignedto'
  has_many :part_images, :class_name => 'EbyDefPartImage', :foreign_key => 'thedef', :order => 'partnum asc'
  has_many :events, :class_name => 'EbyDefEvent', :foreign_key => 'thedef'

  # validations
  validates_inclusion_of :status, :in => %w( Problem Partial GotOrphans NeedTyping NeedProof NeedFixup NeedPublish Published )
  validates_associated :assignee

  def self.query_by_user_size_and_action(to_user, size, action)
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
    return " from eby_defs inner join (select thedef from eby_def_part_images group by thedef having count(*) #{sizecond}) as temp on eby_defs.id = temp.thedef where assignedto is NULL and eby_defs.status = '#{status}' #{wherecond}" 

  end
  def self.assign_def_by_size(to_user, size, action)
    sql = 'select eby_defs.* '+self.query_by_user_size_and_action(to_user, size, action)
    rset = EbyDef.find_by_sql(sql+" limit 1")  
    if rset.nil? or rset[0].nil?
      return nil
    else
      thedef = rset[0]
      thedef.assignedto = to_user.id
      thedef.save
      return thedef
    end
  end
  def self.count_by_action_and_size(user, action, size)
    sql = 'select count(eby_defs.id) '+self.query_by_user_size_and_action(user, size, action)
    return EbyDef.count_by_sql(sql)
  end

  def render_body_as_html
    ret_body = ''
    ret_footnotes = ''
    # first, mass-replace source, comment, and problem markup.
    buf = (deftext.nil? ? '' : deftext)
    buf.gsub!(/\[\[#{I18n.t(:type_comment)}:\s*([^\]]+?)\]\]/, '<span class="comment">\1</span>')
    buf.gsub!(/\[\[#{I18n.t(:type_source)}:\s*([^\]]+?)\]\]/, '<span class="source">\1</span>')
    buf.gsub!(/\[\[#{I18n.t(:type_problem_btn)}:\s*([^\]]+?)\]\]/, '<span class="problem">\1</span>')

    # renumber footnote references, starting with 1
    newbuf = ''
    footnote_num = 1
    foots = {}
    while buf =~ /\[(\d+)\]/ do  
      newbuf += $` + "[#{footnote_num.to_s}]" 
      foots[$1] = footnote_num.to_s
      footnote_num += 1
      buf = $'
    end
    buf = newbuf + buf
    # next, mass-replace now-renumbered footnote references with spans
    buf.gsub!(/\[(\d+)\]/, '<span class="footnote_ref">\1</span>')
    ret_body = buf
    # prepare footnotes
    buf = (footnotes.nil? ? '' : footnotes)
    newbuf = ''
    prefix = ''
    while buf =~ /\[(\d+)\]/ do
      newbuf += $` + prefix + '<span class="footnote_num">'+foots[$1]+'</span><span class="footnote"> '
      buf = $'
      prefix = '</span>'
    end
    ret_footnotes = newbuf + buf + prefix
    return [ret_body, ret_footnotes]
  end
end
