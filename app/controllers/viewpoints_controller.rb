class ViewpointsController < ApplicationController
  respond_to :html, :js, :json
  before_action :authenticate_user!, except: :index
  
  def create
    @event = Event.friendly.find(params[:event_id])
    @instance = @event.instances.friendly.find(params[:instance_id])
    if params[:userphoto]
      if @instance.userphotos.by_user(current_user).to_a.delete_if{|x| !x.userphotoslot.nil? }.size < 2 || !current_user.userphotoslots.empty.empty?
        @u = Userphoto.new(userphoto_params)
        @u.user = current_user
        if @instance.userphotos.by_user(current_user).to_a.delete_if{|x| !x.userphotoslot.nil? }.size == 2
          current_user.userphotoslots.empty.first.userphoto = @u
          
        end
        @instance.userphotos << @u
        if @u.save
          flash[:notice] = t(:your_viewpoint_has_been_saved)
          redirect_to event_instance_path(@instance.event, @instance)
        end
      end

    end
    if params[:userthought]
      @u = Userthought.new(userthought_params)
      @u.user = current_user
      @instance.userthoughts << @u
      if @u.save
        redirect_to event_instance_path(@instance.event, @instance)
        flash[:notice] = t(:your_viewpoint_has_been_saved)
      end
    end
  end
  
  def destroy
    @event = Event.friendly.find(params[:event_id])
    @instance = @event.instances.friendly.find(params[:instance_id])

    @u = params[:viewpoint_type].capitalize.constantize.find(params[:id])
    @viewpoint_type = params[:viewpoint_type]
    if @u.user == current_user || current_user.has_role?(:admin)
      @u.destroy
      flash[:notice] = t(:your_viewpoint_has_been_removed)

    end
  end
  
  def index
    @instance = Instance.friendly.find(params[:id])
    @event = @instance.event
    @viewpoints = @instance.viewpoints
  end
  
  def update
    @event = Event.friendly.find(params[:event_id])
    @instance = @event.instances.friendly.find(params[:instance_id])
    if params[:userphoto]
      @u = Userphoto.find(params[:id])
      if @u.update_attributes(userphoto_params)

          
      end
    end
  end
  
  protected
  
  def userphoto_params
    params.require(:userphoto).permit(:image, :caption, :credit)
  end
  
  def userthought_params
    params.require(:userthought).permit(:thoughts)
  end
   
end