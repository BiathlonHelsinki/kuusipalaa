class EventsController < ApplicationController

  before_action :authenticate_user!, except: [:calendar, :index, :archive, :fullcalendar]

  before_action :set_item, only: [:show, :edit, :update, :destroy]
  
  def index
    @events = Instance.published.future.order(:start_at)
  end

  def archive
    @events = Instance.kuusi_palaa.published.past.order(start_at: :desc)
    render template: 'events/index'
  end

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
      if @events.empty?
        @events = Instance.kuusi_palaa.calendered.published.not_cancelled

      end
      @events = @events.to_a
      @events.flatten!
      @events.each do |event|

        @cal.event do |e|
          next if event.start_at.blank?
          e.dtstart     = Icalendar::Values::DateTime.new(event.start_at, 'tzid' => tzid)
          e.dtend       = Icalendar::Values::DateTime.new(event.end_at, 'tzid' => tzid)
          e.summary     = event.name
          e.location  = 'Kuusi Palaa, Kolmas linja 7, Helsinki'
          e.description = ActionController::Base.helpers.strip_tags( event.description )
          e.ip_class = 'PUBLIC'
          if event.slug =='closed'
            e.url = e.uid = 'https://kuusipalaa.fi/posts/courtyard-closed-thursday-31-may'
          else
            e.url = e.uid = 'https://kuusipalaa.fi/events/' + event.event.slug + '/' + event.slug
          end
        end
      end

      @cal.publish
    end
    set_meta_tags title: 'Calendar'

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @events }
      format.ics { 

        render :plain => @cal.to_ical }
    end
  end
  

  def create
    # if params[:event][:image]
      
    # else
    #   #  no image upload so use idea image
    #   idea = Idea.find(params[:event][:idea_id])
    #   if idea.image?
    #     params[:event][:remote_image_url] = idea.image.url.gsub(/development/, 'production')
    #   end
    # end
    #  now, grab image on the server side and let them change it afterwards
    api = BiathlonApi.new
    success = api.api_post("/events", {user_email: current_user.email,   
      user_token: current_user.authentication_token, event: params[:event].permit!.to_hash} 
      )

    if success["id"]
       Activity.create(item: Event.find(success['id']).instances.first, user: current_user, contributor_type: params['event']['primary_sponsor_type'], contributor_id: params['event']['primary_sponsor_id'], description: 'published_event')
      redirect_to "/events/#{success['id']}"
    elsif success["error"]
      flash[:error] = success["error"]
      redirect_to idea_path(params[:event][:idea_id])
    end
  end

  def fullcalendar
    # events = Event.none
    # events = Event.published.between(params['start'], params['end']) if (params['start'] && params['end'])
    @events = []
    # @events += events.map{|x| x.instances.published}.flatten
    @events += Instance.calendered.published.between(params['start'], params['end']) if (params['start'] && params['end'])
    @events += Idea.active.timed.unconverted.between(params['start'], params['end']) if (params['start'] && params['end'])
    @events += Roombooking.between(params['start'], params['end']) if (params['start'] && params['end'])
    @events.uniq!
    @events.flatten!
    closed = Instance.new(start_at: '2018-07-01 00:00:01', end_at: '2018-12-31 23:59:59')
    closed.name = 'Kuusi Palaa will close permanently without enough stakeholders to support it!'
    closed.slug = 'closed'
    @events << closed
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

  def show
    @event = Event.friendly.find(params[:id])
    if @event.start_at < "2018-02-01" 
      redirect_to "https://temporary.fi/events/" + @event.slug
    end
    set_meta_tags title: @event.name
  end

  def update
    if can? :update, @event
      if @event.update_attributes(event_params)
        flash[:notice] = t(:event_has_been_updated)
      else
        flash[:error] = t(:error_updating_event) + @event.errors.full_messages
      end
    else
      flash[:error] = t(:generic_error)
    end
    redirect_to @event
  end

  private

  def event_params
    params.require(:event).permit(:place_id, :start_at, :end_at, :sequence, :published, :image, :primary_sponsor_id, :primary_sponsor_type,
        :secondary_sponsor_id, :cost_euros, :cost_bb, :idea_id, :remote_image_url,
        instances_attributes: [:id, :_destroy, :event_id, :cost_bb, :price_public, :start_at, :end_at, :image, 
                                :custom_bb_fee,
                                :room_needed, :allow_others, :price_stakeholders, :place_id, 
                                translations_attributes: [:id, :locale, :_destroy, :name, :description]],
                              translations_attributes: [:name, :description, :id, :locale])
  end


  def set_item
    @event = Event.friendly.find(params[:id])
    redirect_to action: action_name, id: @event.friendly_id, status: 301 unless @event.friendly_id == params[:id]
  end
end