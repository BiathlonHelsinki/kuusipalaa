class HomeController < ApplicationController

  def index
    @posts = Post.by_era(@era.id).published.order(updated_at: :desc, published_at: :desc)
    @meetings = Meeting.upcoming.order(start_at: :asc)
    @stakes = Stake.by_season(@next_season)

    @feed = Idea.active.unconverted
    @feed += @posts.reverse

    @feed += Instance.calendered.future.published.map(&:event).uniq
    @visitors_so_far = InstancesUser.where(visit_date: Time.current.to_date).size
    @back_room =  Roombooking.between(Time.current.to_date,Time.current.to_date) + Instance.between(Time.current.to_date, Time.current.to_date).where("room_needed <> 1")
    @main_room = Instance.between(Time.current.to_date, Time.current.to_date).where("room_needed <> 2")
    @event_count = [@back_room , @main_room].flatten.uniq.size
    render layout: 'frontpage'
  end

end
