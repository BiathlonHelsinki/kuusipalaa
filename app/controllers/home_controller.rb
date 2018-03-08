class HomeController < ApplicationController

  def index
    @posts = Post.front.by_era(@era.id).published.order(updated_at: :desc, published_at: :desc)
    @meetings = Meeting.upcoming.order(start_at: :asc)
    @stakes = Stake.by_season(@next_season)

    @feed = Idea.active.unconverted
    @feed += @posts.reverse

    @feed += Instance.calendered.future.published.map(&:event).uniq
    @visitors_so_far = InstancesUser.where(visit_date: Time.current.to_date).size
    @back_room =  Roombooking.between(Time.current.to_date,Time.current.to_date) + Instance.calendered.between(Time.current.to_date, Time.current.to_date).where("room_needed <> 1")
    @main_room = Instance.calendered.between(Time.current.to_date, Time.current.to_date).where("room_needed <> 2")
    @event_count = [@back_room , @main_room].flatten.uniq.size
    @events = [Instance.on_day(Time.current.to_date), Roombooking.between(Time.current.to_date,Time.current.to_date)].flatten
    @today = Time.current.localtime.to_date
    @activities = Activity.order(id: :desc).limit(4)
    @proposals = Idea.unconverted.active.where(ideatype_id: 1).order(updated_at: :desc).limit(5)
    render layout: 'frontpage'
  end

  def front_calendar
    @events = [Instance.on_day(params[:day]), Roombooking.between(params[:day],params[:day])].flatten
    @today = params[:day]
  end

end
