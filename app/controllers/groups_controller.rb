class GroupsController < ApplicationController

  before_action :authenticate_user!

  def create
    @group = Group.new(group_params)
    @group.members << Member.new(user: current_user, source: @group, access_level: KuusiPalaa::Access::OWNER)

    if @group.save
      flash[:notice] = t(:your_group_has_been_created)
      if @group.is_member
        redirect_to basic_details_group_path(@group)
      else
        redirect_to '/members'
      end
    else
      flash[:error] = @group.errors.full_messages
      if @group.is_member
        render template: 'groups/member_details'
      else
        render template: 'groups/new'
      end
    end

  end

  def basic_details
    @group = Group.friendly.find(params[:id])
    @group.members <<  Member.new(user: current_user, source: @group, access_level: KuusiPalaa::Access::OWNER)
    flash[:notice] = t(:one_more_step)


  end

  def edit
    @group = Group.friendly.find(params[:id])
  end

  def new
    @group = Group.new
  end

  def group_members_agreement
    @followup = params[:group_type]
    @members_agreement = 'membership agreement coming soon'
  end

  def group_nonmember_agreement
    @followup = params[:group_type]
    @members_agreement = 'non-member agreement coming soon'
  end

  def member_details
    @group = Group.new(is_member: true)

  end

  def new_nonmember
    @group = Group.new(is_member: false)
  
  end

  def new_registered

  end

  def new_unregistered
    @group = Group.new(is_member: false)
    render template: 'groups/basic_details'
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
    params.require(:group).permit(:name, :long_name, :description, :avatar, :website, :twitter_name, :contact_phone,
    :address, :city, :postcode, :country, :taxid, :accepted_agreement, :is_member)
  end

end
