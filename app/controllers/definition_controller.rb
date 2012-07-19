class DefinitionController < ApplicationController
  def list
    @status = params[:status] || 'NeedPublish'
    @defs = EbyDef.where(:status => @status).page(params[:page])

  end

  def review
  end

  def publish
  end

  def reproof
  end
end
