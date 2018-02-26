class HomeController < ApplicationController

  def index
    @posts = Post.by_era(@era.id).published.order(updated_at: :desc, published_at: :desc)
    @meetings = Meeting.upcoming.order(start_at: :asc)
    @stakes = Stake.by_season(@next_season)

    @feed = Idea.active.unconverted
    @feed += @posts.reverse

    @feed += Instance.calendered.future.published.map(&:event).uniq

    render layout: 'frontpage'
  end

end
