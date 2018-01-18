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
    if current_user.groups.empty? || current_user.is_member? || !current_user.groups.where(["taxid is not null"]).empty?
      @season = Season.find(params[:season_id])
      @stake = Stake.new(season: @season, bookedby: current_user)
    else
      flash[:notice] = t(:you_must_become_member)
      redirect_to members_agreement_users_path
    end
  end


  def index
    @user = User.friendly.find(params[:user_id])
    @stakes = @user.stakes.order(created_at: :desc)
    @stakes += @user.groups.map(&:stakes).flatten
    @stakes.uniq!
  end

  def new

    @season = Season.find(params[:season_id])
    @stake = Stake.new(season: @season, bookedby: current_user)

    if params[:group_id]
      @group = Group.friendly.find(params[:group_id])
      if @group.taxid.blank? && !current_user.is_member?
        flash[:notice] = t(:you_must_become_member)
        redirect_to members_agreement_users_path and return
      else
        fill_collection
        if @group.members.map(&:user).include?(current_user)
          if @group.members.find_by(user: current_user).access_level > KuusiPalaa::Access::REGULAR_MEMBER
            @stake.price = @group.is_member ? 75 : 100
            render template: 'stakes/group_stakes'
          else
            flash[:error] = t(:must_be_admin_to_buy_stakes)
          end
        else
          flash[:error] = t(:must_be_admin_to_buy_stakes)
        end
      end

    else
      fill_collection
      render template: 'stakes/new'
    end
  end

  def show
    @season = Season.find(params[:season_id])
    @stake = Stake.find(params[:id])
  end

  def fill_collection
    @collection_options = []
    @collection_options << [current_user.name, current_user.id, 'User', nil, 50, false]
    last = ''
    unless current_user.members.empty?
      current_user.members.each do |m|
        if m.access_level >= KuusiPalaa::Access::ADMIN
          if @group
            if m.source == @group
              last = [m.source.long_name.blank? ? m.source.name : m.source.long_name, m.source.id, 'Group', nil, m.source.stake_price, m.source.charge_vat?.to_s]
            else
              @collection_options << [m.source.long_name.blank? ? m.source.name : m.source.long_name, m.source.id, 'Group', nil,  m.source.stake_price, m.source.charge_vat?.to_s]
            end
          end

        else

          @collection_options << [m.source.name + t(:only_owners_can_buy), m.source.id, 'Group', 'disabled']
        end
      end
    end
    unless last.blank?
      @collection_options.unshift(last)
    end
  end

  protected

  def stake_params
    params.require(:stake).permit(:owner_type, :owner_id, :season_id, :price, :amount, :bookedby_id, :notes)
  end

end
