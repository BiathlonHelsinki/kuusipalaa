class MeetingsController < ApplicationController
  before_action :authenticate_user!, only: [:cancel_rsvp, :rsvp]

  def cancel_rsvp
    if params[:id]
      @meeting = Meeting.friendly.find(params[:id])
      if @meeting.in_future?
        rsvp = Rsvp.find_or_create_by(meeting: @meeting, user: current_user)
        if rsvp.destroy
          Activity.create(user: current_user, addition: 0, item: @meeting, description: 'is_no_longer_planning_to_attend')
          flash[:notice] = t(:unregistered)
          redirect_to @meeting
        end
      end
    else
      flash[:error] = 'Error'
      redirect_to '/'
    end
  end



  def index
    @meetings = Meeting.published.order(end_at: :desc)

    set_meta_tags title: 'News'
  end

  def rsvp
    if params[:id]
      @meeting = Meeting.friendly.find(params[:id])
      Rsvp.find_or_create_by(meeting: @meeting, user: current_user)
      Activity.create(user: current_user, addition: 0, item: @meeting, description: 'plans_to_attend')
      flash[:notice] = t(:rsvp_thanks)
      redirect_to @meeting
    else
      flash[:error] = 'Error'
      redirect_to '/'
    end
  end


  def show
    @meeting = Meeting.friendly.find(params[:id])
    set_meta_tags title: @meeting.name
  end

end
