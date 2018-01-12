class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @user = User.friendly.find(params[:user_id])
    if @user != current_user
      @error = 'You cannot edit another user\'s email notifications.'
    else
      if params[:meeting_id]
        @item = Meeting.friendly.find(params[:meeting_id])
      elsif params[:post_id]
        @item = Post.friendly.find(params[:post_id])
      end
      unless @item.notifications.by_user(current_user).empty?
        @item.notifications.by_user(current_user).first.destroy
      end
      n = Notification.new(notifications_params)


      n.user = current_user

      @item.notifications << n
      if @item.save
        @error = nil
      end
    end
  end

  def update
    @user = User.friendly.find(params[:user_id])
    if @user != current_user
      @error = 'You cannot edit another user\'s email notifications.'
    else
      if params[:meeting_id]
        @item = Meeting.friendly.find(params[:meeting_id])
      elsif params[:post_id]
        @item = Post.friendly.find(params[:post_id])
      end
      unless @item.notifications.by_user(current_user).empty?
        @item.notifications.by_user(current_user).first.destroy
      end
      n = Notification.new(notifications_params)


      n.user = current_user

      @item.notifications << n
      if @item.save
        @error = nil
      end
    end
  end


  protected

  def notifications_params
    params.require(:notification).permit(:pledges, :comments, :scheduling)
  end

end
