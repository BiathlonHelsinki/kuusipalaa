class HomeController < ApplicationController

  before_action :authenticate_stakeholder!, only: [:stakeholders, :raha]


  def raha
    @expenses = Expense.all.order(date_spent: :asc)
    @paid_stakes = Stake.paid
    @osuukset = Stake.paid.to_a.delete_if{|x| x.amount_osuus == 0}
    @membership_fees = Stake.paid.to_a.delete_if{|x| x.amount_liittymismaksu == 0}
    @stakes_themselves = Stake.paid.to_a.delete_if{|x| x.amount_stake_without_alv == 0}
    @unpaid_stakes_not_late = Stake.booked_unpaid.where(["invoice_due >= ?", 3.weeks.ago])
    @unpaid_stakes_late = Stake.booked_unpaid.where(["invoice_due < ?", 3.weeks.ago])
    @bankstatements = Bankstatement.order(updated_at: :desc)
  end

  def stakeholders
    # stakeholders area
    @pages = Page.published.stakeholders
    @posts = Post.published.stakeholders.order(updated_at: :desc).limit(3)
  end
  
  def index
    @posts = Post.front.not_sticky.by_era(@era.id).published.not_stakeholders.order(updated_at: :desc, published_at: :desc)
    @sticky = Post.sticky.by_era(@era.id).published.not_stakeholders.order(updated_at: :desc, published_at: :desc)
    @meetings = Meeting.upcoming.order(start_at: :asc)
    @stakes = Stake.by_season(@next_season)

    @feed = Idea.active.unconverted
    @feed += @posts.reverse
    @email = Email.sent.order(sent_at: :desc).last
    @feed += Instance.calendered.future.published.uniq{|x| [x.event_id, x.sequence ]}
    @visitors_so_far = InstancesUser.where(visit_date: Time.current.to_date).size + Onetimer.unclaimed.where(["created_at >= ? and created_at <= ?", Time.current.to_date.at_midnight.to_s(:db), Time.current.to_date.end_of_day.to_s(:db)]).size
    @back_room =  Roombooking.between(Time.current.to_date,Time.current.to_date) + Instance.calendered.between(Time.current.to_date, Time.current.to_date).where("room_needed <> 1")
    @main_room = Instance.calendered.between(Time.current.to_date, Time.current.to_date).where("room_needed <> 2")
    @event_count = [@back_room , @main_room].flatten.uniq.size
    @events = [Instance.on_day(Time.current.to_date), Roombooking.between(Time.current.to_date,Time.current.to_date)].flatten
    @today = Time.current.localtime.to_date
    @activities = Activity.order(id: :desc).limit(4)
    @proposals = Idea.unconverted.active.where(ideatype_id: 1).order(updated_at: :desc).limit(5)
    @season = @current_season
    render layout: 'frontpage'
  end

  def front_calendar
    if !params[:day].blank?
      @events = [Instance.on_day(params[:day]), Roombooking.between(params[:day],params[:day])].flatten
      @today = params[:day]
      if params[:day] == '2018-04-25'
        closed = Instance.new(start_at: '2018-04-25 00:00:00', end_at: '2018-04-25 23:59:00')
        closed.name = 'Kuusi Palaa is closed for renovations'
        closed.slug = 'closed'
        @events = [ closed ]
      end
    else
      head :ok,  content_type: "text/html"
    end
  end

  def funders_update
    if params[:season_id]
      @season = Season.find(params[:season_id])
      unless request.xhr?
        head :ok, content_type: "text/html"
      end
    else
      redirect_to '/'
    end
  end

end
