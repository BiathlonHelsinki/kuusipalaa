class IdeasController < ApplicationController

  before_action :authenticate_user!, except: [:index]

  def calendar
    #  build month
    @times = []
    start = params['start'].to_date
    enddate = params['end'].to_date
    (start..enddate).each do |day|
      next if day < Time.now.utc.to_date
      @times << {title: t(:choose) + l(day.to_date, format: :short), day: day, start: "#{day} 00:00:01".to_s, end:  "#{day} 23:59:59".to_s, allDay: true, recurring: false, url: "choose_day/#{day.to_s}"}

    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @times }
    end
  end

  def create
    if params[:step1] == 'event'
      @idea = Idea.create(status: 'building', ideatype_id: 1, proposer: current_user, user: current_user)
      redirect_to idea_build_index_path(idea_id: @idea.id)
    elsif params[:step1] == 'installation'
      @idea = Idea.create(status: 'building', ideatype_id: 2, proposer: current_user, user: current_user)
      redirect_to idea_thing_index_path(idea_id: @idea.id)
    elsif params[:step1] == 'request'
      @idea = Idea.create(status: 'building', ideatype_id: 3, proposer: current_user, user: current_user)
      redirect_to idea_request_index_path(idea_id: @idea.id)
    end
  end

  def index
    @ideas = Idea.active.order(updated_at: :desc)
  end

  def new
    @idea = Idea.new(status: 'building')
  end

  def show
    @idea = Idea.friendly.find(params[:id])
    if user_signed_in?

      if current_user.pledges.unconverted.where(item: @idea).empty?
        @pledge = @idea.pledges.build
      else
        # flash[:notice] = 'You already have an unspent pledge towards this proposal. You can edit or delete it but you cannot create a new one.'
        @pledge = current_user.pledges.unconverted.find_by(item: @idea)
      end 
    end 
    set_meta_tags tite: @idea.name
    unless @idea.active?
      flash[:error] = t(:idea_not_published_yet)
      redirect_to ideas_path
    end
  end

end