class Admin::StakesController < Admin::BaseController


  def create
    @stake = Stake.new(stake_params)
    if @stake.save
      flash[:notice] = 'Stake saved.'
      redirect_to admin_stakes_path
    else
      flash[:error] = "Error saving stake!"
      render template: 'admin/stakes/new'
    end
  end

  def destroy
    stake = Stake.find(params[:id])
    stake.destroy!
    redirect_to admin_stakes_path
  end

  def edit
    @stake = Stake.find(params[:id])
  end

  def index
    @stakes = Stake.all.order(created_at: :desc)
    set_meta_tags title: 'News'
  end

  def new
    @stake = Stake.new
  end

  def update
    @stake = Stake.find(params[:id])
    if @stake.update_attributes(stake_params)
      flash[:notice] = 'Stake details updated.'
      if @stake.paid == true
        if @stake.owner_type == 'User'
          @stake.owner.add_role :stakeholder
        end
      end
      redirect_to admin_stakes_path
    else
      flash[:error] = 'Error updating stake'
    end
  end
  protected

  def stake_params
    params.require(:stake).permit(:published, :place_id, :start_at, :end_at,
      :era_id, :image, :cancelled, :paid, :paid_at,
      translations_attributes: [:id, :locale, :name, :description ]
      )
  end

end
