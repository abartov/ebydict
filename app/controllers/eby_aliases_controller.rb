REVIEW_GROUP_SIZE = 15

class EbyAliasesController < ApplicationController
  def review
    @alias_stats = { defs: EbyDef.count, published: EbyDef.where(status: ['NeedPublish', 'Published']).count, aliases: EbyAlias.count, todo: EbyDef.where(assignedto: nil, status: ['NeedPublish', 'Published'], aliases_done: [nil, false]).count}
    @todo = EbyDef.where(assignedto: current_user.id, aliases_done: [nil, false]) # start with any leftover assigned pieces
    unless @todo.count >= REVIEW_GROUP_SIZE
      moredefs = EbyDef.where(assignedto: nil, aliases_done: [nil, false]).limit(REVIEW_GROUP_SIZE - @todo.count)
      moredefs.update_all(assignedto: current_user.id)
      @todo += moredefs
    end
    @workset = @todo.map{|thedef| [thedef, thedef.generate_aliases]}
  end

  def confirm
    d = EbyDef.find(params[:id])
    unless d.nil?
      existing = d.aliases.pluck(:alias)
      unless existing.include?(params[:the_alias])
        EbyAlias.new(eby_def_id: d.id, alias: params[:the_alias]).save!
      end
      head :ok
    else
      head :bad_request
    end
  end

  def finish
    d = EbyDef.find(params[:id])
    unless d.nil?
      d.aliases_done = true
      d.assignedto = nil
      d.save!
      head :ok
    else
      head :bad_request
    end
  end
end
