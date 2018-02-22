class RoombookingsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  before_action :authenticate_user!, only: [:new, :create, :update, :cancel]
  
  def calendar
    @roombookings = Roombooking.between([params['start'].to_date, '2018-03-01'.to_date].max, params['end']) if (params['start'] && params['end'])

    # @events += events.reject{|x| !x.one_day? }
    if params[:format] == 'ics'
      require 'icalendar/tzinfo'
      @cal = Icalendar::Calendar.new
      @cal.prodid = '-//Kuusi Palaa, Helsinki//NONSGML ExportToCalendar//EN'

      tzid = "Europe/Helsinki"
      tz = TZInfo::Timezone.get tzid
      @roombookings.each do |event|
        @cal.event do |e|
          e.dtstart     = Icalendar::Values::DateTime.new(event.start_at, 'tzid' => tzid)
          e.dtend       = Icalendar::Values::DateTime.new(event.end_at, 'tzid' => tzid)
          e.summary     = event.name
          e.location  = 'Kuusi Palaa, Kolmas linja 7, Helsinki'
          e.description = strip_tags event.description
          e.ip_class = 'PUBLIC'
          e.url = e.uid = 'https://kuusipalaa.fi/roombookings/' + event.id.to_s
        end
      end
      @cal.publish
    end
    set_meta_tags title: 'Calendar'
    #
    # add existing proposals and events

    @roombookings = @roombookings.to_a
    ([params['start'].to_date, '2018-03-01'.to_date].max.to_date..params[:end].to_date).each do |d|

      next if d < Time.current.to_date
      # if user_signed_in?
      #   others = Roombooking.between(d.at_beginning_of_week, d.at_end_of_week)
      #   if others.where(user: current_user).size < 3
      #     @roombookings << {id: nil, title: I18n.t(:book_this_day), start: d.strftime('%Y-%m-%d 00:00:01'),
      #                       end: d.strftime('%Y-%m-%d 23:59:59'), allDay: true, day: d, url: new_roombooking_path(day: d)}
      #   else
      #     @roombookings << {id: nil, title: 'Sorry, the room can only be booked a max. of 3 days per week per person!', start: d.strftime('%Y-%m-%d 00:00:01'),
      #                       end: d.strftime('%Y-%m-%d 23:59:59'), allDay: true, day: d}
      #   end
      # else
        
      @roombookings << {id: nil, title: I18n.t(:book_this_day), start: d.strftime('%Y-%m-%d 00:00:01'),
                          end: d.strftime('%Y-%m-%d 23:59:59'), allDay: true, day: d, url: new_roombooking_path(day: d)}
      # end
    end
    @roombookings +=  Idea.active.timed.unconverted.back_room.between(params['start'], params['end'])  if (params['start'] && params['end'])

    additionaltimes = Additionaltime.between(params['start'], params['end']).to_a.delete_if{|x| !x.item.converted_id.nil?}.delete_if{|x| x.item.room_needed == 1}
    additionaltimes.each do |i|
      newinstance = i
      newinstance.start_at = i.start_at - 1.hour
      @roombookings.push newinstance
    end  

    instances = Instance.calendered.published.back_room.between(params['start'], params['end']) if (params['start'] && params['end'])
    instances.each do |i|
      newinstance = i
      newinstance.start_at = i.start_at - 1.hour
      @roombookings.push newinstance
    end    


    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @roombookings }
      format.ics { render :text => @cal.to_ical }
    end
  end
  
  def create

    @current_rate = params[:roombooking][:points_needed].to_i
    if current_user.latest_balance < params[:roombooking][:points_needed].to_i
      flash[:error] = t(:not_enough_to_book)
    else
      if params[:roombooking][:start_at_date]
        params[:roombooking][:start_at] = params[:roombooking][:start_at_date] + ' ' + params[:roombooking][:start_at]
        params[:roombooking][:end_at] = params[:roombooking][:end_at_date] + ' ' + params[:roombooking][:end_at]
      end

      if @api_status == false #|| @dapp_status == false
        flash[:error] = 'The Biathlon API is currently down. Please try again later.'
        redirect_to roombookings_path
      else
        api = BiathlonApi.new
        
        success = api.api_post("/users/#{current_user.id}/roombookings",
                                 {user_email: current_user.email, 
                                  user_token: current_user.authentication_token,
                                  booker_type: params[:roombooking][:booker_type], 
                                  booker_id: params[:roombooking][:booker_id],
                                  start_at: params[:roombooking][:start_at],
                                  end_at: params[:roombooking][:end_at],
                                  cost: params[:roombooking][:points_needed],
                                  purpose: params[:roombooking][:purpose]
                                  })
        if success['error']
          flash[:error] = success['error'].inspect
     
        else      
          flash[:notice] = 'Your booking was successful, thank you!'
        end  
        redirect_to roombookings_path 
      end                     
    end
  end
  
  def index
    @roombookings = Roombooking.all
  end
  
  def new
    @current_rate = 15
    if current_user.latest_balance < @current_rate
      flash[:notice] = t(:not_enough_to_book)
      redirect_to '/roombookings'
    else
      @existing = Roombooking.where(day: params[:day])
      @roombooking = Roombooking.new(day: params[:day], user: current_user)
      fill_collection
      set_meta_tags title: 'Book '
    end
  end
  
  def show
    @roombooking = Roombooking.find(params[:id])
  end
  
  private
  
  def roombooking_params
    params.require(:roombooking).permit(:day, :user_id, :purpose, :rate_id)
  end
    

end