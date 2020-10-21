REVIEW_GROUP_SIZE = 15

class EbyAliasesController < ApplicationController
  def review
    @alias_stats = { defs: EbyDef.count, published: EbyDef.where(status: ['NeedPublish', 'Published']).count, aliases: EbyAlias.count, todo: EbyDef.where(assignedto: nil, status: ['NeedPublish', 'Published'], aliases_done: [nil, false]).count}
    @todo = EbyDef.where(assignedto: current_user.id) # start with any leftover assigned pieces
    unless @todo.count >= REVIEW_GROUP_SIZE
      moredefs = EbyDef.where(assignedto: nil, aliases_done: [nil, false]).limit(REVIEW_GROUP_SIZE - @todo.count)
      moredefs.update_all(assignedto: current_user.id)
      @todo += moredefs
    end
    @workset = @todo.map{|thedef| [thedef, thedef.generate_aliases]}
  end

  def confirm
  end

  def reject
  end
end
