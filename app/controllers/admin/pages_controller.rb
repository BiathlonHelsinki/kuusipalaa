class Admin::PagesController < Admin::BaseController
  
  def create
    @page = Page.new(page_params)
    if @page.save
      flash[:notice] = 'Page saved.'
      redirect_to admin_pages_path
    else
      flash[:error] = "Error saving page!"
      render template: 'admin/pages/new'
    end
  end
  
  def edit
    @page = Page.friendly.find(params[:id])
  end
  
  def new
    @page = Page.new
  end
  
  def update
    @page = Page.friendly.find(params[:id])
    if @page.update_attributes(page_params)
      flash[:notice] = 'Page details updated.'
      redirect_to admin_pages_path
    else
      flash[:error] = 'Error updating page'
    end
  end
  
  def index
    @pages = Page.all
  end
  
  private
  
  def page_params
    params.require(:page).permit(:slug, :image, :published, :remove_image, translations_attributes: [:id, :locale, :page_id, :title, :body])    
  end
  
end