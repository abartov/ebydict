class DefinitionController < ApplicationController
  def list
    @defs = EbyDef.where(:status => 'Published').page(params[:page])
  end
  def listpub
    if check_role('publisher')
      @status = params[:status] || 'NeedPublish'
      @pubdefs = EbyDef.where(:status => @status).page(params[:page])
    else
      flash[:error] = t(:definition_not_publisher)
      redirect_to :action => 'list'
    end
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
