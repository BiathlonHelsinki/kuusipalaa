class EventRegistrationsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    if params[:event_id]
      @event = Event.friendly.find(params[:event_id])
      @instance = @event.instances.friendly.find(params[:instance_id])
      r = Registration.new(instance: @instance, user: current_user)
      if @instance.max_attendees
        if @instance.max_attendees - @instance.registrations.not_waiting.to_a.delete_if{|x| x.new_record?}.size < 1
          r.waiting_list = true
          r.save
        end
      end
      if r.update_attributes(params[:registration].permit!)
        

        flash[:notice] = t(:registration_thanks)
      else
        flash[:error] = 'There was an error registering: ' + r.errors.inspect
      end
      Activity.create(user: current_user, addition: 0, item: @instance, description: 'registered_for')
      redirect_to [@event, @instance]
    else
      flash[:error] = 'Error'
      redirect_to '/'
    end
  end
  
end