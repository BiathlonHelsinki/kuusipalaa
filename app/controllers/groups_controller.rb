class GroupsController < ApplicationController

  before_action :authenticate_user!

  def create
    @group = Group.new(group_params)
    @group.members << Member.new(user: current_user, source: @group, access_level: Experiment2::Access::OWNER)

    if @group.save
      flash[:notice] = t(:your_group_has_been_created)
      redirect_to '/members'
    else
      flash[:error] = @group.errors.full_messages
      render template: 'groups/new'
    end

  end

  def edit
    @group = Group.friendly.find(params[:id])
  end

  def new
    @group = Group.new
  end

  def show
    @group = Group.friendly.find(params[:id])
  end



  def update
    @group = Group.friendly.find(params[:id])
    if @group.update_attributes(group_params)
      flash[:notice] = t(:your_group_has_been_updated)
    else
      flash[:error] = @group.errors.full_messages
    end
    redirect_to '/members'
  end

  protected

  def group_params
    params.require(:group).permit(:name, :long_name, :description, :avatar, :website, :twitter_name)
  end

end
