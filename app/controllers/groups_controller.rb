class GroupsController < ApplicationController

  before_action :authenticate_user!, except: :check_vat

  def create
    @group = Group.new(group_params)
    @group.members << Member.new(user: current_user, source: @group, access_level: KuusiPalaa::Access::OWNER)

    if @group.save
      flash[:notice] = t(:your_group_has_been_created)
      if @group.is_member
        redirect_to basic_details_group_path(@group)
      else
        redirect_to user_groups_path(current_user)
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

  def index
    @groups = current_user.groups
    @user = current_user
  end

  def basic_details
    @group = Group.friendly.find(params[:id])
    @group.members <<  Member.new(user: current_user, source: @group, access_level: KuusiPalaa::Access::OWNER)
    flash[:notice] = t(:one_more_step)


  end


  def check_vat
    render plain: Valvat.new(params[:id]).valid?.to_s
  end

  def edit
    @group = Group.friendly.find(params[:id])
    if params[:accepted_agreement] == 'true'
      @group.update_attribute(:accepted_agreement, true)
      @group.update_attribute(:is_member, true)
    end
  end


  def join_cooperative
    @group = Group.friendly.find(params[:id])
    if @group.is_member == true
      redirect_to @group
    else
      @members_agreement = Page.friendly.find('membership-agreement-organisations') rescue 'membership agreement coming soon'
      render template: 'groups/group_members_agreement'
    end
  end

  def new
    @group = Group.new
  end

  def group_members_agreement
    @followup = params[:group_type]
    @members_agreement = Page.friendly.find('membership-agreement-organisations') rescue 'membership agreement coming soon'
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
    redirect_to user_groups_path(current_user)
  end

  protected

  def group_params
    params.require(:group).permit(:name, :long_name, :description, :avatar, :website, :twitter_name, :contact_phone,
    :address, :city, :postcode, :country, :taxid, :accepted_agreement, :is_member)
  end

end
