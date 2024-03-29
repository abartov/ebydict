require "rexml/document"

class DefinitionController < ApplicationController
  def list
    # @defs = EbyDef.where(:status => 'Published').order("defhead asc").page(params[:page]) # naive, alphabetical sort by defhead --  this won't do!

    # instead, since rendering the defs one after the other is slow and is essentially static and uncustomized,
    # we'll render a static HTML file that is regularly generated by a runner process
    @defs = EbyDef.where(:status => 'Published').order("defhead asc").page(params[:page]) # naive, alphabetical sort by defhead --  this won't do!
    # TODO: replace with static HTML files
  end
  def listpub
    if check_role('publisher')
      @status = params[:status] || 'NeedPublish'
      @pubdefs = EbyDef.where(:status => @status).order(:defhead).page(params[:page])
    else
      flash[:error] = t(:definition_not_publisher)
      redirect_to '/'
    end
  end
  def listall
    if check_role('publisher')
      @alldefs = EbyDef.where.not(defhead: [nil, t(:type_unknown)]).order('defhead asc')
    else
      flash[:error] = t(:definition_not_publisher)
      redirect_to '/'
    end
  end
  def publish
    redirect_to '/' unless check_role('publisher')
    @d = EbyDef.find(params[:id])
    defev = EbyDefEvent.new(:old_status => @d.status, :thedef => @d.id, :who => session['user'].id, :new_status => 'Published')
    defev.save
    @d.status = 'Published'
    @d.save
    flash[:notice] = t(:definition_published_html, :defhead => @d.defhead).html_safe
    redirect_to :action => 'listpub'
  end

  def reproof
    redirect_to '/' unless check_role('publisher')
    @d = EbyDef.find(params[:id])
    @d.status = 'NeedProof'
    @d.save
    flash[:notice] = t(:definition_sent_to_reproof_html, :defhead => @d.defhead).html_safe
    redirect_to :action => 'listpub'
  end
  def unassign
    redirect_to '/' unless check_role('publisher')
    @d = EbyDef.find(params[:id])
    @d.assignee = nil
    @d.save
    redirect_to controller: 'user', action: 'list'
  end
  # process a definition and render it in preview/final mode
  def view
    d = EbyDef.find(params[:id])
    @defhead = d.defhead or ''
    @page_title = "#{@defhead} - #{I18n.t(:definition_from_eby)}"
    (@defbody,@footnotes) = d.render_body_as_html
  end
  def render_tei
    d = EbyDef.find(params[:id])
    #doc = Nokogiri.XML(d.render_tei) do |config|
    #@tei = doc.to_xml(:indent => 2)
    doc = REXML::Document.new(d.render_tei)
    @tei = ''
    doc.write(@tei, 1)
  end
  def split_footnotes
    redirect_to '/' unless check_role('publisher')
    @d = EbyDef.find(params[:id])
    redirect_to '/' if @d.nil?
    @newbuf = ''
    first = true
    @d.footnotes.split(/(\[\d+\] )/).each do |part|
      if part =~ /\[\d+\] /
        unless first
          @newbuf += "</p><p>"
        else
          first = false
        end
      else
        if part =~ /—\s+$/
          part = $`
        end
      end
      @newbuf += part
    end
    @d.footnotes = @newbuf
    @d.save!
  end

  private

  def secure?
    return (not ['view','render_tei'].include?(params[:action]))
  end
end
