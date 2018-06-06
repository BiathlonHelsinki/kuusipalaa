class InstancesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  before_action :authenticate_user!, only: [:rsvp, :cancel_rsvp, :cancel_registration, :add_registration_form]

  def add_registration_form
    if params[:event_id]
      @event = Event.friendly.find(params[:event_id])
      @instance = @event.instances.friendly.find(params[:id])
    end
    if !@instance.responsible_people.include?(current_user)
      flash[:error] = t(:not_authorized)
      redirect_to event_instance_path(@event, @instance)
    end
  end

  def cancel_registration
    if params[:event_id]
      @event = Event.friendly.find(params[:event_id])
      @instance = @event.instances.friendly.find(params[:id])
      if @instance.in_future?
        registration = Registration.find_or_create_by(instance: @instance, user: current_user)
        if registration.destroy
          Activity.create(user: current_user, contributor: current_user,  addition: 0, item: @instance, description: 'is_no_longer_registered_for')
          flash[:notice] = t(:unregistred)
          redirect_to [@event, @instance]
        end
      end
    else
      flash[:error] = 'Error'
      redirect_to '/'
    end
  end

  def index
    if params[:event_id]
      @event = Event.friendly.find(params[:event_id])
      redirect_to action: action_name, event_id: @event.friendly_id, status: 301 and return unless @event.friendly_id == params[:event_id] 
      @future = @event.instances.current.or(@event.instances.future).order(:start_at).uniq
      @past = @event.instances.past.order(:start_at).uniq.reverse
    end
    if @event.start_at < "2018-02-01"  && @event.sequences.size == 1
      redirect_to "https://temporary.fi/events/" + @event.slug and return
    end
    set_meta_tags title: @event.name
    @instance = @event.instances.published.first
    @sequences = @event.instances.order(:start_at).group_by(&:sequence)
    if @instance.nil?
      @instance = @event.instances.first
    end
    @sequence = @sequences[@instance.sequence]
    if @instance.open_time == true
      redirect_to event_instance_path(@event, @instance)
    elsif @sequences.size == 1 && @instance.already_happened? && @event.ideas.empty?
      @archive = true
      render template: 'instances/past'
    elsif @event.sequences.size > 1 || !@event.ideas.empty?
      @project = @event
      render template: 'events/project'
    else
      render template: 'instances/show' 
    end
    # end
  end

  
  def make_organiser
    @event = Event.friendly.find(params[:event_id])
    @instance = @event.instances.friendly.find(params[:id])
  end
      
  def cancel_rsvp
    if params[:event_id]
      @event = Event.friendly.find(params[:event_id])
      @instance = @event.instances.friendly.find(params[:id])
      if (@instance.start_at - 12.hours) > Time.current
        rsvp = Rsvp.find_or_create_by(instance: @instance, user: current_user)
        if rsvp.destroy
          Activity.create(user: current_user, contributor: current_user, addition: 0, item: @instance, description: 'is_no_longer_planning_to_attend')
          flash[:notice] = t(:cancel_rsvp_thanks)
          redirect_to [@event, @instance]
        end
      else
        flash[:error] = t :cannot_cancel_rsvp_12hr
        redirect_to [@event, @instance]
      end
    else
      flash[:error] = 'Error'
      redirect_to '/'
    end
  end
    
  def rsvp
    if params[:event_id] && current_user.can_rsvp?
      @event = Event.friendly.find(params[:event_id])
      @instance = @event.instances.friendly.find(params[:id])
      Rsvp.find_or_create_by(instance: @instance, user: current_user)
      Activity.create(user: current_user, contributor: current_user, addition: 0, numerical_value: 2, item: @instance, description: 'plans_to_attend')
      flash[:notice] = t(:rsvp_thanks)
      redirect_to [@event, @instance]
    else
      flash[:error] = 'Error'
      redirect_to '/'
    end
  end

  def stats
    if params[:event_id]
      @event = Event.friendly.find(params[:event_id])
      @instance = @event.instances.friendly.find(params[:id])
      if @instance.slug =~ /open\-time/ || @instance.name =~ /open time/i 
        if params['start'] && params['end']
          @sessions = Opensession.between(params['start'], params['end'])
          @sessions = @sessions.to_a.delete_if{|x| x.seconds_open < 90 }
        else
          @sessions = Opensession.between(@instance.start_at.beginning_of_month, @instance.end_at.end_of_month)
          if @temporary_is_open == true && Time.current.localtime <= @instance.end_at
            current = Opensession.by_node(1).find_by(closed_at: nil )
          end
          @sessions = @sessions.sort_by{|x| x.id }
          @potential_minutes = ((Time.current - @instance.start_at.beginning_of_month) / 60).to_i
        end
      else
        flash[:notice] = 'No statistics available for regular events.'
        redirect_to event_instance_path(@event, @instance)
      end
    end
    set_meta_tags title: 'Stats'
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @sessions }
    end
  end
    
  def show
    if params[:event_id]

      @event = Event.friendly.find(params[:event_id])
      @instance = @event.instances.friendly.find(params[:id])
      if @instance.start_at < "2018-02-01"  
        redirect_to "https://temporary.fi/events/" + @event.slug + "/#{@instance.slug}" and return
      end
      # if @instance.slug == @event.slug && @event.keep_going != true
      #   redirect_to event_path(@event.slug)
      # else

        set_meta_tags title: @instance.name

        if params[:format] == 'ics'
          require 'icalendar/tzinfo'
          @cal = Icalendar::Calendar.new
          @cal.prodid = '-//Kuusi Palaa, Helsinki//NONSGML ExportToCalendar//EN'

          tzid = "Europe/Helsinki"
          @cal.event do |e|
            e.dtstart     = Icalendar::Values::DateTime.new(@instance.start_at, 'tzid' => tzid)
            e.dtend       = Icalendar::Values::DateTime.new(@instance.end_at, 'tzid' => tzid)
            e.summary     = @instance.name
            e.location  = 'Kuusi Palaa, Kolmas linja 7, Helsinki'
            e.description = strip_tags @instance.description
            e.ip_class = 'PUBLIC'
            e.url = e.uid = 'https://kuusipalaa.fi/events/' + @instance.event.slug + '/' + @instance.slug
          end
          @cal.publish
        end

        if @instance.open_time == true
          @page = Page.friendly.find('kuusi-palaa-open-time')
          render template: 'instances/open_time'

        else  
          @sequence = @instance.event.instances.where(sequence: @instance.sequence).order(:start_at)
          respond_to do |format|
            format.html { 
              if @instance.already_happened? 
                @archive = true
                render  template: 'instances/past' 
              else
                
                render template: 'instances/show'
              end
            }
            format.ics { send_data @cal.to_ical, type: 'text/calendar', disposition: 'attachment', filename: @instance.slug + ".ics" }
          end
        end
      # end 
    end
    
  end
  

  
  def update

    if params[:event_id]
      @event = Event.friendly.find(params[:event_id])
      @instance = @event.instances.friendly.find(params[:id])
    else
      @instance = Instance.friendly.find(params[:id])
    end
    if can? :update, @instance
      if @instance.update_attributes(instance_params)
        flash[:notice] = t(:event_has_been_updated)   
      end
   else
    flash[:error] = t(:not_authorized)
  end
  redirect_to event_instance_path(@instance.event, @instance)
    
  end

  protected

    def instance_params
      params.require(:instance).permit(:request_registration, :max_attendees, :require_approval, :email_registrations_to, 
        :question1_text, :question2_text, :question3_text, :question4_text, :boolean1_text, :boolean2_text, 
        :registration_open,  events_attributes: [:secondary_sponsor], organiser_ids: [], 
        translations_attributes: [:name, :description, :instance_id, :locale, :id]
        )
    end
end

