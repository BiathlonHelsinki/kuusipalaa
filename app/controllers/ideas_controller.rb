class IdeasController < ApplicationController
  before_action :authenticate_user!

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
      @idea = Idea.create(status: 'building', ideatype_id: 1)
      redirect_to idea_build_index_path(idea_id: @idea.id)
    end
  end

  def new
    @idea = Idea.new(status: 'building')

  end

end