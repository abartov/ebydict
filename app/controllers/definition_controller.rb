class DefinitionController < ApplicationController
  def list
    @status = params[:status] || 'NeedPublish'
    @defs = EbyDef.where(:status => @status).page(params[:page])

  end

  def review
    @d = EbyDef.find(params[:id])
  end

  def publish
    @d = EbyDef.find(params[:id])
    @d.status = 'Published'
    @d.save
    flash[:notice] = t(:definition_published_html, :defhead => @d.defhead).html_safe

    redirect_to :action => 'list'
  end

  def reproof
    @d = EbyDef.find(params[:id])
    @d.status = 'NeedProof'
    @d.save
    flash[:notice] = t(:definition_sent_to_reproof_html, :defhead => @d.defhead).html_safe
    redirect_to :action => 'list'
  end
end
