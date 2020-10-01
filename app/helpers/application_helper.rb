# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def filepart_from_path(path)
    return path[(path.rindex('/')+1)..-1]
  end

  def redspan(s)
    return '<span style="color:red; font-size: 250%">'+s+'</span>'
  end
  def small_redspan(s)
    return '<span style="color:red; font-size: 150%">'+s+'</span>'
  end
  def highlight_suspicious_markdown(buf)
    buf.gsub('**', redspan('**')).gsub('| ', redspan('| ')).gsub('##', redspan('##'))
  end

  def mark_markup_in_html(buf)
    return buf.gsub('[[', redspan('[[')).gsub(']]', redspan(']]')).gsub('[', small_redspan('[')).gsub(']', small_redspan(']'))
  end

  def action_label_for_status(s)
    case 
      when s == 'NeedTyping'
        return I18n.t(:type_typing)
      when s =~ /NeedProof/
        return I18n.t(:type_proofing)
      when s == 'NeedFixup'
        return I18n.t(:type_fixups)
      when s == 'Problem'
        return I18n.t(:status_problem)
      when s == 'Partial'
        return I18n.t(:status_partial)
      when s == 'NeedPublish'
        return I18n.t(:status_need_publish)
      when s == 'Published'
        return I18n.t(:status_published)
    end
  end
  def label_for_status(s)
    case
      when s == 'NeedTyping'
        return I18n.t(:status_need_typing)
      when s =~ /NeedProof/
        return I18n.t(:status_need_proofing, :round => $')
      when s == 'NeedFixup'
        return I18n.t(:status_need_fixups)
      when s == 'Problem'
        return I18n.t(:status_problem)
      when s == 'Partial'
        return I18n.t(:status_partial)
      when s == 'NeedPublish'
        return I18n.t(:status_need_publish)
      when s == 'Published'
        return I18n.t(:status_published)
    end
  end

end
