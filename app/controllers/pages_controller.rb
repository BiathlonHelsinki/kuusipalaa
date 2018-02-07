class PagesController < ApplicationController

  def show
    @page = Page.friendly.find(params[:id])
    fill_collection if user_signed_in?
    set_meta_tags title: @page.title
  
  end

end
