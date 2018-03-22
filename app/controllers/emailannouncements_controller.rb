class EmailannouncementsController < ApplicationController

  before_action :authenticate_user!
  before_action :authenticate_stakeholder!

  def create
    @emailannouncement = Emailannouncement.new(emailannouncement_params)
    if @emailannouncement.save
      flash[:notice] = t(:email_announcement_saved)
      redirect_to emailannouncements_path
    else
      flash[:error] = t(:email_announcement_error) + @emailannouncement.errors.full_messages.join('; ')
      @next_email = Email.unsent.order(:send_at).last
      fill_stake_collection
      render template: 'emailannouncements/new'
    end
  end

  def destroy
    emailannouncement = Emailannouncement.find(params[:id])
    season = emailannouncement.season
    emailannouncement.destroy!
    redirect_to season_emailannouncements_path(season)
  end

  def discuss
    @season = Season.find(params[:season_id])
    @emailannouncement = @season.emailannouncements.find(params[:id])
    unless @emailannouncement.fixed == true

      fill_stake_collection
      @voter = current_user
      if current_user.emailannouncement_votes.where(emailannouncement: @emailannouncement).empty?
        @vote = @emailannouncement.emailannouncement_votes.build
      else
        # flash[:notice] = 'You already have an unspent pledge towards this proposal. You can edit or delete it but you cannot create a new one.'
        @vote = current_user.emailannouncement_votes.find_by(emailannouncement: @emailannouncement)
      end 
    end
  end

  def edit
    @emailannouncement = Emailannouncement.find(params[:id])
    @next_email = Email.unsent.order(:send_at).last
    fill_stake_collection
  end 

  def find_vote
    if params[:voter_type] =='Group'
      @voter = Group.find(params[:voter_id])
    elsif params[:voter_type] == 'User'
      @voter = User.find(params[:voter_id])
    end
    @emailannouncement = Emailannouncement.find(params[:id])
    if @voter.emailannouncement_votes.where(emailannouncement: @emailannouncement).empty?
      @vote = @emailannouncement.emailannouncement_votes.build
    else
      @vote = @voter.emailannouncement_votes.find_by(emailannouncement: @emailannouncement)
    end 
    fill_stake_collection
    # render partial: 'emailannouncements/vote_panel'
  end  

  def new
    @next_email = Email.unsent.order(:send_at).last
    @emailannouncement = Emailannouncement.new(email: @next_email, user: current_user, announcer: current_user)
    fill_stake_collection
  end

  def index
    @emailannouncements = Emailannouncement.all
    @next_email = Email.unsent.order(:send_at).last
  end

  def show
    @emailannouncement = Emailannouncement.find(params[:id])
    redirect_to discuss_season_emailannouncement_path(@emailannouncement.season, @emailannouncement)
  end

  def update
    @emailannouncement = Emailannouncement.find(params[:id])
    if @emailannouncement.update_attributes(emailannouncement_params)
      flash[:notice] = 'Email announcement details updated.'
      redirect_to emailannouncements_path
    else
      flash[:error] = 'Error updating email announcement'
    end
  end

  protected
   
    def emailannouncement_params
      params.require(:emailannouncement).permit(:announcer_type, :announcer_id, :user_id,
        :reference_type, :reference_id, :email_id, :only_stakeholders, :message, :published,
        :subject)

    end

end