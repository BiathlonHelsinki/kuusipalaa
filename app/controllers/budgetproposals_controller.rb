class BudgetproposalsController < ApplicationController

  before_action :authenticate_user!
  before_action :authenticate_stakeholder!

  def create
    @budgetproposal = Budgetproposal.new(budgetproposal_params)
    if @budgetproposal.save
      flash[:notice] = 'Budget proposal saved.'
      redirect_to season_budgetproposals_path(@budgetproposal.season)
    else
      flash[:error] = "Error saving budgetproposal!"
       @season = Season.find(params[:season_id])
        @budgetproposals = @season.budgetproposals
      render template: 'budgetproposals/index'
    end
  end

  def destroy
    budgetproposal = Budgetproposal.find(params[:id])
    season = budgetproposal.season
    budgetproposal.destroy!
    redirect_to season_budgetproposals_path(season)
  end

  def discuss
    @season = Season.find(params[:season_id])
    @budgetproposal = @season.budgetproposals.find(params[:id])
    unless @budgetproposal.fixed == true

      fill_stake_collection
      @voter = current_user
      if current_user.budgetproposal_votes.where(budgetproposal: @budgetproposal).empty?
        @vote = @budgetproposal.budgetproposal_votes.build
      else
        # flash[:notice] = 'You already have an unspent pledge towards this proposal. You can edit or delete it but you cannot create a new one.'
        @vote = current_user.budgetproposal_votes.find_by(budgetproposal: @budgetproposal)
      end 
    end
  end

  def edit
    @budgetproposal = Budgetproposal.find(params[:id])
  end 

  def find_vote
    if params[:voter_type] =='Group'
      @voter = Group.find(params[:voter_id])
    elsif params[:voter_type] == 'User'
      @voter = User.find(params[:voter_id])
    end
    @budgetproposal = Budgetproposal.find(params[:id])
    if @voter.budgetproposal_votes.where(budgetproposal: @budgetproposal).empty?
      @vote = @budgetproposal.budgetproposal_votes.build
    else
      @vote = @voter.budgetproposal_votes.find_by(budgetproposal: @budgetproposal)
    end 
    fill_stake_collection
    # render partial: 'budgetproposals/vote_panel'
  end  


  def index
    @season = Season.find(params[:season_id])
    if Time.current.to_date > @season.start_at
      flash[:error] = t(:this_season_has_already_begun)
      redirect_to '/'
    else
      @budgetproposals = @season.budgetproposals
      @budgetproposal = Budgetproposal.new(user: current_user, season: @season, proposer: current_user)
    end
  end

  def show
    @budgetproposal = Budgetproposal.find(params[:id])
    redirect_to discuss_season_budgetproposal_path(@budgetproposal.season, @budgetproposal)
  end

  def update
    @budgetproposal = Budgetproposal.find(params[:id])
    if @budgetproposal.update_attributes(budgetproposal_params)
      flash[:notice] = 'Budget proposal details updated.'
      redirect_to season_budgetproposals_path(@budgetproposal.season)
    else
      flash[:error] = 'Error updating budget proposal'
    end
  end

  protected
   
    def budgetproposal_params
      params.require(:budgetproposal).permit(:season_id, :proposer_id, :proposer_type, :fixed, :user_id, :link, :name, :description, :amount, :status)
    end

end