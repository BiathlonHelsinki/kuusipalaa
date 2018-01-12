class CommentsController < ApplicationController


  before_action :authenticate_user!

  def create
    c = Comment.new(comment_params)
    if params[:post_id]
      @master = Post.friendly.find(params[:post_id])
    end
    if params[:comment_id]
      @master = Comment.find(params[:comment_id])
    end
    if params[:meeting_id]
      @master = Meeting.friendly.find(params[:meeting_id])
    end
    if params[:event_id]
      @master= Event.friendly.find(params[:event_id])
      if comment_params[:frontpage] == "1"
        if current_user != @master.primary_sponsor && current_user != @master.secondary_sponsor
          comment_params[:frontpage] = ''
        end
      end
    end
    @master.comments << c
    unless @master.root_comment.notifications.empty?
      @master.root_comment.notifications.each do |n|
        next unless n.comments == true
        NotificationMailer.new_comment(@master.root_comment, c, n.user).deliver_later
      end
    end
    if @master.save!
      flash[:notice] = t(:your_comment_was_added)
    else
      flash[:error] = t(:your_comment_was_not_added)
    end
    redirect_to c.root_comment
  end

  def destroy
    @comment = Comment.find(params[:id])
    parent = @comment.root_comment
    if can? :destroy, @comment
      @comment.destroy
      flash[:notice] = 'Your comment has been deleted.'
    else
      flash[:error] = ' You do not have permission to delete this comment.'
    end
    redirect_to parent
  end

  protected

  def comment_params
    params.require(:comment).permit(:proposal_id, :item_type, :item_id, :user_id, :content, :frontpage, :attachment, :image)
  end

end
