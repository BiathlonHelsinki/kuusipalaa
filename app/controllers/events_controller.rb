class EventsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  
  def create
    api = BiathlonApi.new
    success = api.api_post("/events", {user_email: current_user.email,   
      user_token: current_user.authentication_token, event: params[:event].permit!.to_hash} 
      )
    if success["data"]
      redirect_to "/events/#{success['data']['id']}"
    else
      flash[:error] = success.to_s
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
    @experiment = Event.friendly.find(params[:id])
    redirect_to action: action_name, id: @experiment.friendly_id, status: 301 unless @experiment.friendly_id == params[:id]
  end
end