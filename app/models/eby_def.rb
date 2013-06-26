class EbyDef < ActiveRecord::Base
  attr_accessible :arabic, :assignedto, :defhead, :deftext, :extra, :footnotes, :greek, :proof_round_passed, :russian, :status, :reject_count
  belongs_to :assignee, :class_name => 'EbyUser', :foreign_key => 'assignedto'
  has_many :part_images, :class_name => 'EbyDefPartImage', :foreign_key => 'thedef', :order => 'partnum asc'
  has_many :events, :class_name => 'EbyDefEvent', :foreign_key => 'thedef'

  # validations
  validates_inclusion_of :status, :in => %w( Problem Partial GotOrphans NeedTyping NeedProof NeedFixup NeedPublish Published )
  validates_associated :assignee

  def self.query_by_user_size_and_action(to_user, size, action, round)
    sizecond = ""
    wherecond = "" # what to add to the WHERE clause
    case action
      when AppConstants.type 
        status = "NeedTyping"
        action = "type"
        wherecond = "ORDER BY reject_count ASC"
      when AppConstants.proof 
        round_part = round.nil? ? '' : " and proof_round_passed = #{(round-1).to_s}"
        status = "NeedProof"
        action = "proof"
        wherecond = " and proof_round_passed < "+to_user.max_proof_level.to_s+round_part+" and #{to_user.id} not in (select who from eby_def_events where thedef = eby_defs.id and new_status LIKE 'NeedProof%') ORDER BY reject_count ASC, proof_round_passed " # prefer to assign highest allowed proofing round, as there are presumably fewer proofers available to work at each successive proof level
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
        wherecond += " ) ORDER BY reject_count ASC"
      else
        throw Exception.new
    end
    case size
      when 'medium'
        sizecond = "= 2"
      when 'large'
        sizecond = "> 2"
      else # assume 'small'
        sizecond = " = 1"
    end
    return " from eby_defs inner join (select thedef from eby_def_part_images group by thedef having count(*) #{sizecond}) as temp on eby_defs.id = temp.thedef where assignedto is NULL and eby_defs.status = '#{status}' #{wherecond}" 

  end
  def self.assign_def_by_size(to_user, size, action, round)
    while round == nil or round > 0
      sql = 'select eby_defs.* '+self.query_by_user_size_and_action(to_user, size, action, round)
      rset = EbyDef.find_by_sql(sql+" limit 1")  
      if rset.nil? or rset[0].nil?
        round -= 1 unless round.nil?
      else
        thedef = rset[0]
        thedef.assignedto = to_user.id
        thedef.save
        return thedef
      end
    end
    return nil
  end
  def self.count_by_action_and_size(user, action, size, round)
    sql = 'select count(eby_defs.id) '+self.query_by_user_size_and_action(user, size, action, round)
    return EbyDef.count_by_sql(sql)
  end
  def status_label
    case self.status
      when "NeedTyping"
        label = I18n.t(:type_await_typing)
      when "NeedProof"
        label = I18n.t(:type_await_proof_round, :round => self.proof_round_passed + 1)
      when "NeedFixup"
        label = I18n.t(:type_await_fixups)
      when "Problem"
        label = I18n.t(:type_await_resolution)
      when "NeedPublish"
        label = I18n.t(:type_await_publishing)
      when "Published"
        label = I18n.t(:type_published)
    end
    return label
  end
  def render_body_as_html
    ret_body = ''
    ret_footnotes = ''
    # first, mass-replace source, comment, and problem markup.
    buf = (deftext.nil? ? '' : deftext)
    buf = mass_replace_html(buf)

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
    buf = mass_replace_html(buf)
    newbuf = ''
    prefix = ''
    while buf =~ /\[(\d+)\]/ do
      if foots[$1].nil?
        newbuf += $` + prefix + '<span class="problem">'+I18n.t(:definition_missing_footnote_body, :num => $1)+'</span>'
        prefix = ''
      else
        #print "$` = #{$`}, $1 = #{$1}, foots = #{foots[$1]}\n"
        newbuf += $` + prefix + '<span class="footnote_num">'+foots[$1]+'</span><span class="footnote"> '
        prefix = '</span>'
      end
      buf = $'
    end
    ret_footnotes = newbuf + buf + prefix
    return [ret_body, ret_footnotes]
  end
  def predecessor_def
    d = nil
    if part_images.first.defno > 0
      # the prev def must be the one ending on this same colimg with defno-1
      return part_images.first.colimg.def_part_by_defno(part_images.first.defno - 1).thedef 
    else
      # we'd have to find the last def of the previous column, which may be on a different page
      # TODO: continue this logic -- find the def, check status, etc.
      return nil
    end
  end 
  def successor_def
  end
  def prev_published?
  end
  def next_published?
  end
  protected
  
  def mass_replace_html(buf)
    buf.gsub!(/\[\[#{I18n.t(:type_source)}:\s*([^\]]+?)\]\]/, '<span class="source">\1</span>')
    buf.gsub!(/\[\[#{I18n.t(:type_comment)}:\s*([^\]]+?)\]\]/, '<span class="comment">\1</span>')
    buf.gsub!(/\[\[#{I18n.t(:type_problem_btn)}:\s*([^\]]+?)\]\]/, '<span class="problem">\1</span>')
    buf.gsub!(/\[\[#{I18n.t(:type_redirect)}:\s*([^\]]+?)\]\]/, '<span class="redirect">\1</span>') # TODO: replace with actual redirecting logic?
    return buf
  end
   
end
