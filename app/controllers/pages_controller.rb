class PagesController < ApplicationController

  def show
    @page = Page.friendly.find(params[:id])
    set_meta_tags title: @page.title
  
  end

end
