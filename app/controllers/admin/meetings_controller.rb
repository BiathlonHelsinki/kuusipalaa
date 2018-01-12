class Admin::MeetingsController < Admin::BaseController


  def create
    @meeting = Meeting.new(meeting_params)
    if @meeting.save
      flash[:notice] = 'Meeting saved.'
      redirect_to admin_meetings_path
    else
      flash[:error] = "Error saving meeting!"
      render template: 'admin/meetings/new'
    end
  end

  def destroy
    meeting = Meeting.friendly.find(params[:id])
    meeting.destroy!
    redirect_to admin_meetings_path
  end

  def edit
    @meeting = Meeting.friendly.find(params[:id])
  end

  def index
    @meetings = Meeting.all.order(created_at: :desc)
    set_meta_tags title: 'News'
  end

  def new
    @meeting = Meeting.new
  end

  def update
    @meeting = Meeting.friendly.find(params[:id])
    if @meeting.update_attributes(meeting_params)
      flash[:notice] = 'Meeting details updated.'
      redirect_to admin_meetings_path
    else
      flash[:error] = 'Error updating meeting'
    end
  end
  protected

  def meeting_params
    params.require(:meeting).permit(:published, :place_id, :start_at, :end_at,
      :era_id, :image, :cancelled,
      translations_attributes: [:id, :locale, :name, :description ]
      )
  end

end
