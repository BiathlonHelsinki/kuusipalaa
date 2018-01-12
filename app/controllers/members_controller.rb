class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_group_admin, except: [:new_group, :leave, :remove, :index, :autocomplete_user_username]
  before_action :authorize_group_member, only: [:leave, :remove]
  autocomplete :user, :username

  def authorize_group_member
    @group = Group.friendly.find(params[:group_id])
    me = @group.members.find_by(user: current_user)
    if me.nil?
      flash[:error] = t(:you_are_not_authorised_for_this_group)
      redirect_to '/members'
    end
  end

  def authorize_group_admin
    @group = Group.friendly.find(params[:group_id])
    me = @group.members.find_by(user: current_user)
    if me.nil?
      flash[:error] = t(:you_are_not_authorised_for_this_group)
      redirect_to '/members'
    elsif me.access_level < Experiment2::Access::ADMIN
      flash[:error] = t(:you_are_not_authorised_for_this_group)
      redirect_to '/members'
    end
  end

  def create

    @member = Member.new(source: @group, access_level: Experiment2::Access::REGULAR_MEMBER, user: User.friendly.find_by(username: member_params[:username]))


    if @member.save
      GroupMailer.new_member(@group, @member).deliver_now
      flash[:notice] = t(:member_has_been_added)
      redirect_to '/members'
    else

      flash[:error] = @member.errors.full_messages
      render template: 'members/new'
    end
  end


  def destroy
    @member = @group.members.find(params[:id])
    # don't delete if last member
    if @group.members.size == 1
      flash[:error] = t(:cannot_have_no_members)
      redirect_to @group
    else
      if @member.destroy

        flash[:notice] = t(:member_has_been_removed)
      end

      if @group.members.size == 1
        new_owner = @group.members.first
        new_owner.update_attribute(:access_level, 50)

        @group.save
      end
      redirect_to new_group_member_path(@group)
    end
  end

  def leave

  end

  def remove
    @membership = @group.members.find_by(user: current_user)
    Activity.create(user: current_user, item: @membership, addition: 0, description: params[:private_leaving] == '1' ? 'privately_left_the_group' : 'left_the_group', extra: @group, extra_info: params[:leaving_reason])
    @membership.destroy
    if @group.members.size == 1
      new_owner = @group.members.first
      new_owner.update_attribute(:access_level, 50)

      @group.save
    end
    redirect_to @group
  end

  def new_group
    @group = Group.new
  end

  def new
    @member = Member.new(source: @group)
  end

  def update
    @member = @group.members.find(params[:id])
    if @member.update_attributes(member_params)
      flash[:notice] = t(:member_access_level_has_been_updated)
    else
      flash[:error] = @member.errors.full_messages
    end
    redirect_to @group
  end

  protected

  def member_params
    params.require(:member).permit(:username, :access_level)

  end
end
