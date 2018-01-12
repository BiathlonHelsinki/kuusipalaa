class Admin::SeasonsController < Admin::BaseController

  def create
    @season = Season.new(season_params)
    if @season.save
      flash[:notice] = 'Season saved.'
      redirect_to admin_seasons_path
    else
      flash[:error] = "Error saving season!"
      render template: 'admin/seasons/new'
    end
  end

  def edit
    @season = Season.find(params[:id])
  end

  def new
    @season = Season.new
  end

  def update
    @season = Season.find(params[:id])
    if @season.update_attributes(season_params)
      flash[:notice] = 'Season details updated.'
      redirect_to admin_seasons_path
    else
      flash[:error] = 'Error updating season'
    end
  end

  def index
    @seasons = Season.all
  end

  private

  def season_params
    params.require(:season).permit(:slug, :number, :start_at, :end_at, :stake_count)
  end

end
