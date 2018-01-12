class Admin::PostsController < Admin::BaseController


  def create
    @post = Post.new(post_params)
    if @post.save
      flash[:notice] = 'Post saved.'
      redirect_to admin_posts_path
    else
      flash[:error] = "Error saving post: " + @post.errors.inspect
      render template: 'admin/posts/new'
    end
  end

  def destroy
    post = Post.friendly.find(params[:id])
    post.destroy!
    redirect_to admin_posts_path
  end

  def edit
    @post = Post.friendly.find(params[:id])
  end

  def index
    @posts = Post.by_era(@era.id).order(created_at: :desc)
    set_meta_tags title: 'News'
  end

  def new
    @post = Post.new(era: @era, user: current_user)
  end

  def update
    @post = Post.friendly.find(params[:id])
    if @post.update_attributes(post_params)
      flash[:notice] = 'Post details updated.'
      redirect_to admin_posts_path
    else
      flash[:error] = 'Error updating post'
    end
  end

  protected

  def post_params
    params.require(:post).permit(:published, :era_id, :user_id, :sticky, :meeting_id, :instance_id,
     :published_at, :image, :remove_image, :postcategory_id,
      translations_attributes: [:id, :locale, :title, :body ]
      )
  end

end
