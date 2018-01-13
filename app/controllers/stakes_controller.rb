class StakesController < ApplicationController
  before_action :authenticate_user!


  def create
    @season = Season.find(params[:season_id])
    @stake = Stake.new(stake_params)
    if @stake.save
      flash[:notice] = t(:stake_booked_invoice_later)
      redirect_to season_stake_path(@season, @stake)
    else

      flash[:error] = t(:error_booking_stake) + " : " + @stake.errors.messages.values.join('; ')
      fill_collection
      render template: 'stakes/new'
    end
  end


  def for_self

    @season = Season.find(params[:season_id])
    @stake = Stake.new(season: @season, bookedby: current_user)
    if !current_user.is_member? &&  params[:accepted_agreement] != 'true'
      redirect_to members_agreement_users_path
    elsif !current_user.has_membership_details?
      redirect_to get_membership_details_user_path(current_user)
    end
  end

  def for_group
    @season = Season.find(params[:season_id])
    @stake = Stake.new(season: @season, bookedby: current_user)
    fill_collection
  end

  def new
    @season = Season.find(params[:season_id])
    @stake = Stake.new(season: @season, bookedby: current_user)
    fill_collection
  end

  def show
    @season = Season.find(params[:season_id])
    @stake = Stake.find(params[:id])
  end

  def fill_collection
    @collection_options = []
    @collection_options << [current_user.name, current_user.id, 'User', nil]
    unless current_user.members.empty?
      current_user.members.each do |m|
        if m.access_level > Experiment2::Access::ADMIN
          @collection_options << [m.source.name, m.source.id, 'Group', nil]
        else
          @collection_options << [m.source.name + t(:only_owners_can_buy), m.source.id, 'Group', 'disabled']
        end
      end
    end
  end

  protected

  def stake_params
    params.require(:stake).permit(:owner_type, :owner_id, :season_id, :amount, :bookedby_id, :notes)
  end

end
