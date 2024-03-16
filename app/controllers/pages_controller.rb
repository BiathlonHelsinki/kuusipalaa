class PagesController < ApplicationController
  # load_and_authorize_resource find_by: :slug
  caches_page :show
  skip_before_action :check_consents, only: :show
  def show
    @page = Page.friendly.find(params[:id])
    authorize! :read, @page, message: "Unable to read this page."
    fill_collection if user_signed_in?
    set_meta_tags(title: @page.title)
  end
end
