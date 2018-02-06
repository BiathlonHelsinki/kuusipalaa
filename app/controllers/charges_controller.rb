class ChargesController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    # Amount in cents
    @stake = Stake.find(params[:stake_id])
    if @stake.bookedby == current_user

      begin
        customer = Stripe::Customer.create(
          :email => params[:stripeEmail],
          :source  => params[:stripeToken]
        )
      rescue Faraday::ClientError => e
        flash[:error] = e.message
        redirect_to new_charge_path
      end 
      begin
        charge = Stripe::Charge.create(
          :customer    => customer.id,
          :amount      => params[:amount] * 100,
          :description => 'Kuusi Palaa stakes purchase',
          :currency    => 'eur'
        )

      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to new_charge_path

      end 

      @stake.update_attribute(:paid, true)
      @stake.update_attribute(:paid_at, Time.now.utc)
      @stake.update_attribute(:paymenttype_id, 2)
      @stake.update_attribute(:stripe_token, params[:stripeToken])
  
    else
      flash[:error] = t(:this_is_not_your_stake)
      redirect_to season_stake_path(@stake.season, @stake)
    end

  end

end
