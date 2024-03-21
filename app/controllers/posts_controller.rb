class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[new edit destroy create update]
  before_action :authenticate_stakeholder!, only: [:stakeholders]
  caches_page :index, :show
  def create
    @post = Post.new(post_params)
    @post.published = true
    if @post.save
      @post.notifications << Notification.new(user: current_user, comments: true)
      flash[:notice] = 'Post saved.'
      redirect_to(@post.only_stakeholders == true ? stakeholders_posts_path : '/')
    else
      flash[:error] = "Error saving post: " + @post.errors.inspect
      render(template: 'posts/new')
    end
  end

  def destroy
    post = Post.friendly.find(params[:id])
    post.destroy!
    redirect_to('/')
  end

  def edit
    @post = Post.friendly.find(params[:id])
  end

  def index
    @posts = Post.published.by_era(@era.id).not_stakeholders.order(updated_at: :desc)
    @stakeholders = false
    # @posts += Comment.frontpage
    set_meta_tags(title: 'Topics')
  end

  def new
    @post = Post.new
    @post.only_stakeholders = params[:only_stakeholders]
  end

  def show
    @post = Post.friendly.find(params[:id])
    if cannot?(:read, @post)
      redirect_to(posts_path)
    else
      set_meta_tags(title: @post.title)
    end
  end

  def stakeholders
    @posts = Post.published.stakeholders
    @stakeholders = true
    render(template: 'posts/index')
  end

  def update
    @post = Post.friendly.find(params[:id])
    if @post.update_attributes(post_params)
      flash[:notice] = 'Post details updated.'
      redirect_to('/')
    else
      flash[:error] = 'Error updating post'
    end
  end

  protected

  def post_params
    params.require(:post).permit(:era_id, :user_id, :meeting_id,
                                 :published_at, :only_stakeholders,
                                 translations_attributes: %i[id locale title body])
  end
end
