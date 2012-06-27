# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def filepart_from_path(path)
    return path[(path.rindex('/')+1)..-1]
  end
end
