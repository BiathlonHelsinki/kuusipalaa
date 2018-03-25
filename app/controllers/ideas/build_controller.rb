class Ideas::BuildController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!
  steps :find_type, :name_and_info, :when, :points, :finalise

  def show
    begin
      @idea = Idea.friendly.find(params[:idea_id])
      fill_collection
      render_wizard
    rescue ActiveRecord::RecordNotFound 
      redirect_to new_idea_path
    end
  end

  def update
    @idea = Idea.find(params[:idea_id])

    if params[:idea][:ideatype_id] == "4"
      @idea.destroy

      redirect_to roombookings_path
    else
      params[:idea][:status] = step.to_s
      params[:idea][:status] = 'active' if step == steps.last
      @idea.add_to_activity_feed if step == steps.last
      if step == :when || step == :points
        if params[:idea][:start_at_date]
          params[:idea][:start_at] = Time.parse(params[:idea][:start_at_date] + ' ' + params[:idea][:start_at]).getutc
          params[:idea][:end_at] = Time.parse(params[:idea][:end_at_date] + ' ' + params[:idea][:end_at]).getutc
        end
        if params[:idea][:additionaltimes_attributes]
          params[:idea][:additionaltimes_attributes].permit!.to_hash.each_with_index do |pa, index|
            next if params[:idea][:additionaltimes_attributes]["#{pa.first}"][:start_at].blank? || params[:idea][:additionaltimes_attributes]["#{pa.first}"][:end_at].blank?
            params[:idea][:additionaltimes_attributes]["#{pa.first}"][:start_at] = Time.parse(pa.last["start_at_date"] + ' ' + pa.last["start_at"]).getutc
            params[:idea][:additionaltimes_attributes]["#{pa.first}"][:end_at] = Time.parse(pa.last["end_at_date"] + ' ' + pa.last["end_at"]).getutc
          end
        end        
      end
      if @idea.update_attributes(idea_params)
        if params[:form_direction] == 'previous'
          redirect_to wizard_path(previous_step, :idea_id => @idea.id)
        else
          fill_collection
          render_wizard @idea
        end
      else
        flash[:error] = @idea.errors.full_messages.join('; ')
      end
    end
  end


  def create
    @idea = Idea.create
    redirect_to wizard_path(steps.first, :idea_id => @idea.id)
  end

  def finish_wizard_path
    '/ideas'
  end


  private

    def idea_params
      params.require(:idea).permit([:ideatype_id, :status, :form_direction, :timeslot_undetermined, :start_at, :end_at, :price_public, :room_needed, :price_stakeholders, :allow_others, :name, :short_description, :proposal_text,
                                    :proposer_id, :proposer_type, :special_notes, :image, :hours_estimate,
                                    :points_needed, additionaltimes_attributes: [:id, :_destroy, :start_at, :end_at]])
    end
end

