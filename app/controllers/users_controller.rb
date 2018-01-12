class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:mentions, :check_unique]


  def buy_photoslot
    @user = User.friendly.find(params[:id])
    if @user == current_user
      @user.update_balance_from_blockchain
      if @user.latest_balance < 1
        render plain: 'Sorry, you need at least 1 Temp to do this.'
      end

      if @api_status == false
        render plain: 'The Biathlon API is currently down. Please try again later.'
      else
        api = BiathlonApi.new

        success = api.api_post("/users/#{@user.id}/userphotoslots/buy_slot",
                               {user_email: @user.email,
                                user_token: @user.authentication_token
                                })
        if success['error']
          render plain: success['error']
        else

        end
      end
    else
      render plain: 'This is not you.'
    end
  end

  def check_unique
    if User.where("lower(username) = ?", params[:username].downcase).exists? || Group.where("lower(name) = ?",  params[:username].downcase).exists?
      render json:{message: 'Username is taken'}, status: 422
    else
      head :ok
    end
  end

  def edit
    # users can edit their own profile, somewhat
    @user = User.friendly.find(params[:id])
    if cannot? :update, @user
      flash[:error] = 'You cannot edit another user profile'
      redirect_to '/'
    end
    set_meta_tags title: 'Edit your profile'
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

  def mentions
    if params[:mentioning][0] == '@'
      @users = User.where("lower(username) LIKE '%" +  params[:mentioning][1..-1].downcase + "%'")
      @users += User.where("lower(name) LIKE '%" +  params[:mentioning][1..-1].downcase + "%'")
      logger.warn('mentions are ' + @users.uniq.map(&:as_mentionable).to_json )
      render json: @users.uniq.map(&:as_mentionable).to_json
    elsif params[:mentioning][0] == '#'
      # @events = Event.joins(:translations).where("lower(event_translations.name) LIKE '%" +  params[:mentioning][1..-1].downcase + "%'")
      # @events += Instance.joins(:translations).where("lower(instance_translations.name) LIKE '%" +  params[:mentioning][1..-1].downcase + "%'").map(&:event)

      # render json: @events.uniq.map(&:as_mentionable).to_json
      @posts = Post.joins(:translations).where("lower(post_translations.title) LIKE '%" + params[:mentioning][1..-1].downcase + "%'")
      render json: @posts.uniq.map(&:as_mentionable).to_json

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
    redirect_to action: action_name, id: @user.friendly_id, status: 301 unless @user.friendly_id == params[:id]
    set_meta_tags title: @user.display_name
  end

  def update
    @user = User.friendly.find(params[:id])
    if can? :update, @user
      if @user.update_attributes(user_params)
        flash[:error] = ''
        flash[:warning] = ''
    
        flash[:notice] = 'Profile info saved.'
        redirect_to @user
      else
        flash[:error] = @user.errors.full_messages.join('. ')
        render template: 'users/edit'
      end
    else
      flash[:error] = 'You cannot edit another user profile'
      redirect_to '/'
    end
  end

  protected

  def user_params
    params.require(:user).permit(:email, :name, :username, :show_name,  :avatar,  :opt_in, :website, :twitter_name,
    :address, :postcode, :city, :country, :show_twitter_link, :show_facebook_link,
                      accounts_attributes: [:address, :primary_account, :external])
  end
end
