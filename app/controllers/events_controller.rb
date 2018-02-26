class EventsController < ApplicationController

  before_action :authenticate_user!, except: [:calendar]

  before_action :set_item, only: [:show, :edit, :update, :destroy]
  
   def calendar
    # events = Event.none
    # events = Event.published.between(params['start'], params['end']) if (params['start'] && params['end'])
    @events = []
    # @events += events.map{|x| x.instances.published}.flatten
    @events += Instance.calendered.published.between(params['start'], params['end']) if (params['start'] && params['end'])

    @events.uniq!
    @events.flatten!
 
    # @events += events.reject{|x| !x.one_day? }
    if params[:format] == 'ics'
      require 'icalendar/tzinfo'
      @cal = Icalendar::Calendar.new
      @cal.prodid = '-//Kuusi Palaa, Helsinki//NONSGML ExportToCalendar//EN'

      tzid = "Europe/Helsinki"
      tz = TZInfo::Timezone.get tzid
      @events.delete_if{|x| x.cancelled == true }.each do |event|
      
        @cal.event do |e|
          e.dtstart     = Icalendar::Values::DateTime.new(event.start_at, 'tzid' => tzid)
          e.dtend       = Icalendar::Values::DateTime.new(event.end_at, 'tzid' => tzid)
          e.summary     = event.name
          e.location  = 'Kuusi Palaa, Kolmas linja 7, Helsinki'
          e.description = strip_tags event.description
          e.ip_class = 'PUBLIC'
          e.url = e.uid = 'https://kuusipalaa.fi/events/' + event.event.slug + '/' + event.slug
        end
      end
      @cal.publish
    end
    set_meta_tags title: 'Calendar'
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @events }
      format.ics { render :text => @cal.to_ical }
    end
  end
  

  def create
    if params[:event][:image]
      die
    else
      #  no image upload so use idea image
      idea = Idea.find(params[:event][:idea_id])
      if idea.image?
        params[:event][:remote_image_url] = idea.image.url.gsub(/development/, 'production')
      end
    end

    api = BiathlonApi.new
    success = api.api_post("/events", {user_email: current_user.email,   
      user_token: current_user.authentication_token, event: params[:event].permit!.to_hash} 
      )

    if success["id"]
      redirect_to "/events/#{success['id']}"
    elsif success["error"]
      flash[:error] = success["error"]
      redirect_to idea_path(params[:event][:idea_id])
    end
  end


  def show
    @event = Event.friendly.find(params[:id])
    set_meta_tags title: @event.name
  end

  private

  def event_params
    #  none, send everything to the biathlon API to create it
  end


  def set_item
    @event = Event.friendly.find(params[:id])
    redirect_to action: action_name, id: @event.friendly_id, status: 301 unless @event.friendly_id == params[:id]
  end
end