class OnetimersController < ApplicationController
  
  before_action :authenticate_user!
  
  def link
    
  end
  
  def link_tag
    tag = Onetimer.where('lower(code) =?',  params[:code].downcase).first
    if tag
      api = BiathlonApi.new
      success = api.api_post('/link_temporary_tag', {user_id: current_user.id, tag_id: tag.id})
      if success['error']
        flash[:error] = success['error']
        redirect_to('/link_temporary')
      else
        current_user.latest_balance += tag.instance.cost_bb
        current_user.save(validate: false)
 
        flash[:notice] = t(:your_ticket_was_converted)
        redirect_to('/')
      end
    end
  end
  
end