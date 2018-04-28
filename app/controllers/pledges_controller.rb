class PledgesController < ApplicationController

  before_action :authenticate_user!
  
  
  def create

    get_pledger_and_item

    if !@pledger.pledges.unconverted.where(item: @item).empty? 
      flash[:notice] = t(:illegal_pledge)
   
      redirect_to @item
    elsif @item.converted?
      flash[:notice] = t(:illegal_pledge)
      redirect_to @item
    elsif @item.cancelled?
      flash[:error] = t(:this_proposal_was_cancelled)
      redirect_to @item

    else
      if @balance < params[:pledge][:pledge].to_i
        flash[:error] = 'You do not have this many ' + ENV['currency_full_name']
        redirect_to new_proposal_pledge_path(@proposal)
      end
      if params[:pledge][:pledge].to_i > @item.max_for_user(@pledger, @pledge)
        flash[:error] = t(:you_cannot_pledge_this_much)
        redirect_to @item
      else
        @pledge = Pledge.new(pledge_params)
        @pledge.item = @item
        # if @item.class == Event
        #   @pledge.item_type = 'Event'
        # else
        #   @pledge.item_type = @item.class.to_s
        # end
        @pledge.user = current_user
        @pledge.pledger = @pledger
        @pledge.converted = false
        if @pledge.save
          unless @item.notifications.empty?
            @item.notifications.each do |n|
              next unless n.pledges == true
              NotificationMailer.new_pledge(@item, @pledge, n.user).deliver_later
            end
          end
          @pledge.item.reload
          @pledge.item.notify_if_enough
          redirect_to @item
        else

          flash[:error] = 'There was an error saving your pledge: ' + @pledge.errors.messages.values.join('; ')
          redirect_to @item
        end
      end
    end
  end
  
  def destroy
    @item = Proposal.find(params[:proposal_id])
    @pledge = @item.pledges.find(params[:id])
    if @pledge.destroy!
      flash[:notice] = 'Your pledge has been withdrawn.'
      redirect_to @item 
    else
      flash[:error] = "There was an error withdrawing your pledge."
    end
  end
  
  def edit
    @next_meeting = Instance.next_meeting
    @current_rate = Rate.get_current.experiment_cost
    if params[:proposal_id]
      @item = Proposal.find(params[:proposal_id])
    elsif params[:event_id]
      @item = Event.friendly.find(params[:event_id])
    end
    @pledge = @item.pledges.find(params[:id])
    
  end
  
  def find_pledge
    if params[:pledger_type] =='Group'
      @pledger = Group.find(params[:pledger_id])
    elsif params[:pledger_type] == 'User'
      @pledger = User.find(params[:pledger_id])
    end
    if params[:idea_id]
      @item = Idea.friendly.find(params[:idea_id])
      @idea = @item
    end
    if @pledger.pledges.unconverted.where(item: @item).empty?
      @pledge = @item.pledges.build
    else
      @pledge = @pledger.pledges.unconverted.find_by(item: @item)
    end 
    render partial: 'ideas/pledge_panel'
  end


  def new
    if params[:proposal_id]
      @item = Proposal.includes(:pledges => [:user]).find(params[:proposal_id])
    elsif params[:event_id]
      @item = Event.includes(:pledges => [:user]).find(params[:event_id])
    elsif params[:idea_id]
      @item = Idea.friendly.find(params[:idea_id])
    end
    if @item.stopped? || !@item.is_valid?
      flash[:error] = 'This event has finished.'
      redirect_to proposals_path
    else
      @next_meeting = Instance.next_meeting
      @current_rate = Rate.get_current.experiment_cost
      if current_user.pledges.unconverted.where(item: @item).empty?
        @pledge = @item.pledges.build
      else
        flash[:notice] = 'You already have an unspent pledge towards this proposal. You can edit or delete it but you cannot create a new one.'
        @pledge = current_user.pledges.unconverted.find_by(item: @item)
      end
    end
  end
  
  
  def update
    get_pledger_and_item
    if @item.cancelled?
      flash[:error] = t(:this_proposal_was_cancelled)
      redirect_to @item
    else
      @pledge = @item.pledges.find(params[:id])
      if params[:pledge][:pledge].to_i > @item.max_for_user(@pledger, @pledge)
        flash[:error] = 'You can\'t pledge this much!'
        redirect_to new_proposal_pledge_path(@item)
      else
        if @pledge.update_attributes(pledge_params)
          flash[:notice] = 'Your pledge has been edited!'
          @pledge.item.notify_if_enough
          redirect_to @item
        else
          flash[:error] = 'There was an error saving your edited pledge: ' + @pledge.errors.values.join
          redirect_to @item
        end
      end
    end
  end
  
    
  protected
  
  def get_pledger_and_item
    @pledger = params[:pledge][:pledger_type].constantize.find(params[:pledge][:pledger_id])
    @pledger.update_balance_from_blockchain
    @balance = @pledger.latest_balance
    if params[:proposal_id]
      @proposal = Proposal.find(params[:proposal_id])
      @item = @proposal
    elsif params[:idea_id]
      @idea = Idea.friendly.find(params[:idea_id])
      @item = @idea

    elsif params[:event_id]
      @item = Event.friendly.find(params[:event_id])
    end
  end

  def pledge_params
    params.require(:pledge).permit(:item_id, :item_type, :pledge, :pledger_type, :pledger_id, :user_id, :comment)
  end
  
end
