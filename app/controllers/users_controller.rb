class UsersController < ApplicationController
  before_action :authenticate_user!, except: %i[mentions check_unique show get_avatar]
  skip_before_action :check_consents, only: :consent

  def buy_photoslot
    @user = User.friendly.find(params[:id])
    if @user == current_user
      @user.update_balance_from_blockchain
      render(plain: t(:sorry_need_1p)) if @user.latest_balance < 1

      if @api_status == false
        render(plain: t(:api_is_down))
      else
        api = BiathlonApi.new

        success = api.api_post("/users/#{@user.id}/userphotoslots/buy_slot",
                               { user_email: @user.email,
                                 user_token: @user.authentication_token })

        if success['error']
          render(plain: success['error'])
        else

        end
      end
    else
      render(plain: 'This is not you.')
    end
  end

  def consent
    @toc = Page.friendly.find('kp-terms-and-conditions')
  end

  def set_pin
    @user = current_user
  end

  def check_unique
    if User.where("lower(username) = ?", params[:username].downcase).exists? || Group.where("lower(name) = ?", params[:username].downcase).exists?
      render(json: { message: 'Username is taken' }, status: :unprocessable_entity)
    else
      head(:ok)
    end
  end

  def edit
    # users can edit their own profile, somewhat
    @user = User.friendly.find(params[:id])
    if cannot?(:update, @user)
      flash[:error] = 'You cannot edit another user profile'
      redirect_to('/')
    end
    set_meta_tags(title: 'Edit your profile')
  end

  def get_avatar
    if params[:class] == 'Group'
      render(plain: Group.find(params[:id]).avatar.url(params[:size].to_sym))
    elsif params[:class] == 'User'
      render(plain: User.find(params[:id]).avatar.url(params[:size].to_sym))
    end
  end

  def get_membership_details
    @user = User.friendly.find(params[:id])
  end

  def make_organiser
    @event = Event.friendly.find(params[:event_id])
    @instance = @event.instances.friendly.find(params[:id])
    @user = User.friendly.find(params[:user_id])
    if @instance.responsible_people.include?(current_user) || current_user.has_role?(:admin)
      @instance.organisers << @user
      @instance.save
      @success = true
    else
      @success = false
    end
  end

  def members_agreement
    @members_agreement = begin
      Page.friendly.find('membership-agreement')
    rescue StandardError
      'membership agreement coming soon'
    end
  end

  def mentions
    if params[:mentioning][0] == '@'
      @users = User.where("lower(username) LIKE '%" + params[:mentioning][1..-1].downcase + "%'")
      @users += User.where("lower(name) LIKE '%" +  params[:mentioning][1..-1].downcase + "%'")
      logger.warn('mentions are ' + @users.uniq.map(&:as_mentionable).to_json)
      render(json: @users.uniq.map(&:as_mentionable).to_json)
    elsif params[:mentioning][0] == '#'
      @events = Event.published.joins(:translations).where("lower(event_translations.name) LIKE '%" +  params[:mentioning][1..-1].downcase + "%'")
      @events += Instance.published.joins(:translations).where("lower(instance_translations.name) LIKE '%" + params[:mentioning][1..-1].downcase + "%'").map(&:event)

      # render json: @events.uniq.map(&:as_mentionable).to_json
      # @posts = Post.joins(:translations).where("lower(post_translations.title) LIKE '%" + params[:mentioning][1..-1].downcase + "%'")
      render(json: @events.uniq.map(&:as_mentionable).to_json)

    end
  end

  def remove_organiser
    @event = Event.friendly.find(params[:event_id])
    @instance = @event.instances.friendly.find(params[:id])
    @user = User.friendly.find(params[:user_id])
    if @instance.responsible_people.include?(current_user) || current_user.has_role?(:admin)
      @instance.organisers.delete(@user)
      @instance.save
      @success = true
    else
      @success = false
    end
  end

  def show
    @user = User.friendly.find(params[:id])
    redirect_to(action: action_name, id: @user.friendly_id, status: :moved_permanently) unless @user.friendly_id == params[:id]
    set_meta_tags(title: @user.display_name)
  end

  def stakeholder_refund
    @user = current_user
  end

  def update
    @user = User.friendly.find(params[:id])
    if can? :update, @user
      if @user.update_attributes(user_params.except(:buy_stakes_after_edit))

        flash[:notice] = t(:your_details_have_been_updated)
        if params[:user][:buy_stakes_after_edit]
          redirect_to(for_self_season_stakes_path(@current_season.id, accepted_agreement: true))
        else
          redirect_to(session[:return_to].nil? ? @user : session[:return_to])
        end
      else
        flash[:error] = @user.errors.full_messages.join('. ')
        render(template: 'users/edit')
      end
    else
      flash[:error] = 'You cannot edit another user profile'
      redirect_to('/')
    end
  end

  protected

  def user_params
    params.require(:user).permit(:email, :name, :username, :phone, :show_name, :pin, :avatar, :opt_in, :website, :twitter_name,
                                 :address, :postcode, :city, :country, :accepted_agreement, :opt_in_ready, :opt_in_points, :opt_in_mentions, :opt_out_everything,
                                 :opt_in_weekly_newsletter, :accepted_tos, :show_twitter_link, :contact_phone, :iban, :other_bank_details,
                                 :show_facebook_link, :buy_stakes_after_edit,
                                 accounts_attributes: %i[address primary_account external])
  end
end
