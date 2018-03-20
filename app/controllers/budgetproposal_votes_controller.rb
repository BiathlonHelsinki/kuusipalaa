class BudgetproposalVotesController < ApplicationController

  before_action :authenticate_user!
  before_action :authenticate_stakeholder!

  def create
    @season = Season.find(params[:season_id])
    @budgetproposal = @season.budgetproposals.find(params[:budgetproposal_id])

    @budgetproposalvote = BudgetproposalVote.new(budgetproposalvotes_params)
    @budgetproposalvote.budgetproposal = @budgetproposal
    @budgetproposalvote.user = current_user
    if @budgetproposalvote.save
      flash[:notice] = t(:voting_success)
    else
      flash[:error] = t(:voting_error)
    end
    redirect_to season_budgetproposal_path(@budgetproposal.season, @budgetproposal)
  end

  def destroy
    budgetproposal = Budgetproposal.find(params[:id])
    season = budgetproposal.season
    budgetproposal.destroy!
    redirect_to season_budgetproposals_path(season)
  end

  def update
    @season = Season.find(params[:season_id])
    @budgetproposal = @season.budgetproposals.find(params[:budgetproposal_id])
    @budgetproposalvote = @budgetproposal.budgetproposal_votes.find(params[:id])

    if @budgetproposalvote.update_attributes(budgetproposalvotes_params)
      flash[:notice] = t(:voting_success)
    else
      flash[:error] = t(:voting_error)
    end
    redirect_to season_budgetproposal_path(@budgetproposal.season, @budgetproposal)
  end

  protected

    def budgetproposalvotes_params
      params.require(:budgetproposal_vote).permit(:vote, :voter_type, :voter_id, :user_id)
    end


end