class Ideas::BuildController < ApplicationController
  include Wicked::Wizard

  steps :find_type, :name_and_info, :when, :points, :finalise

  def show
    @idea = Idea.friendly.find(params[:idea_id])
    render_wizard
  end

  def update
    @idea = Idea.find(params[:idea_id])
    params[:idea][:status] = 'active' if step == steps.last
    @idea.update_attributes(idea_params)
    if @idea.ideatype_id == 4
      @idea.destroy
      redirect_to '/pages/private-event'
    else
      render_wizard @idea
    end
  end


  def create
    @idea = Idea.create
    redirect_to wizard_path(steps.first, :idea_id => @idea.id)
  end

  private

  def idea_params
    params.require(:idea).permit([:ideatype_id, :timeslot_undetermined, :start_at])
  end
end

