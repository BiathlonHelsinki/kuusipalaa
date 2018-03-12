class TransfersController < ApplicationController
  
  before_action :authenticate_user!
  
  def send_points
    if params[:user_id]
      @recipient = User.friendly.find(params[:user_id])
    elsif params[:group_id]
      @recipient = Group.friendly.find(params[:group_id])
    end

    if @api_status == false #|| @dapp_status == false
      flash[:error] = 'The Biathlon API is currently down. Please try again later.'
      redirect_to @recipient
    else
      current_user.update_balance_from_blockchain
      render template: 'transfers/send_points'
    end
  end
  
  
  
  def post_points
    @sender = params[:sender_type].constantize.find(params[:sender_id])
    if params[:sender_type] == 'Group'
      if !@sender.privileged.include?(current_user)
        flash[:notice] = t(:you_are_not_authorised_for_this_group)
        redirect_to @sender
      end
    end
    if params[:user_id]
      @recipient = User.friendly.find(params[:user_id])
      url = "/users/#{params[:user_id]}/transfers/send_biathlon"
    elsif params[:group_id]
      @recipient = Group.friendly.find(params[:group_id])
      url = "/groups/#{params[:group_id]}/transfers/send_biathlon"
    end

    @photo = params[:userphoto_id].nil? ? nil : params[:userphoto_id]
    if @api_status == false 
      flash[:error] = 'The Biathlon API is currently down. Please try again later.'
      if request.xhr?
      else
        redirect_to @recipient
      end
    else
      if params[:points_to_send].to_s !~ /\A[-+]?[0-9]*\.?[0-9]+\Z/ || current_user.available_balance < params[:points_to_send].to_i
        flash[:error] = t(:generic_error)
        redirect_to @recipient
      else
        api = BiathlonApi.new
        
        success = api.api_post(url,
                               {user_email: current_user.email, 
                                user_token: current_user.authentication_token,
                                from_account: @sender.accounts.first.address,
                                points: params[:points_to_send],
                                reason: params[:reason], 
                                userphoto_id: @photo
                                })
        if success['error']
          flash[:error] = success['error']
          redirect_to send_points_user_transfers_path(@recipient)
        else      
          TransfersMailer.received_points(current_user, @recipient, params[:points_to_send], params[:reason]).deliver                   
          flash[:notice] = 'Your transfer was successful, thank you!'
          if request.xhr?
          else
            redirect_to @recipient
          end
        end   
      end                     
    end
  end
  
end