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

  # process a definition and render it in preview/final mode
  def view
    d = EbyDef.find(params[:id])
    @defhead = d.defhead or ''
    @page_title = "#{@defhead} - #{I18n.t(:definition_from_eby)}"
    (@defbody,@footnotes) = d.render_body_as_html
  end

  private
  
  def secure?
    return (params[:action] != 'view')
  end
end
