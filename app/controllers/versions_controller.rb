class VersionsController < ApplicationController
  #version details
  def index
    @html =  params[:v].to_s+".html.erb"
    render :html => params[:v].to_s+".html.erb"
  end
  
end
