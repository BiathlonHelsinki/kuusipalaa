class AuthenticationsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:index, :show, :create]
  
  def add_provider
    if params[:user_email] != current_user.email
      render status: 403, json: { message: 'You are not authorised to do this.' }
    else
      authentication = Authentication.find_by(provider: params[:provider], user: current_user)
      if authentication.nil?
        if params[:username]
          authentication = Authentication.new(provider: params[:provider], user_id: current_user.id, username: params[:username])
        elsif params[:uid]
          authentication = Authentication.new(provider: params[:provider], user_id: current_user.id, uid: params[:uid])
        end
        if authentication.save
          render status: 200, json: {message: 'Authentication added to database.'}
        else
          logger.warn('errors are ' + authentication.errors.inspect)
          render status: 422, json: {message: 'Error saving authentication method.'}
        end
      else
        
        render status: 422, json: {message: 'Authentication already exists for this user.'}
      end
    end
      
  end
  
  def create
    
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      #render status: 200, json: { email: authentication.user.email, authentication_token: authentication.user.authentication_token, id: authentication.user.id }
      sign_in_and_redirect(:user, authentication.user)
    # elsif current_user
    #   current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])

    elsif auth = Authentication.find_by_username_and_provider(omniauth['info']['nickname'], omniauth['provider'])
      auth.update(:provider => omniauth['provider'], :uid => omniauth['uid'], :username => omniauth['info']['nickname'])
      user = auth.user
      #render status: 200, json: { email: user.email, authentication_token: user.authentication_token, id: id }
      sign_in_and_redirect(:user, user)

    # see if they have the auth defined without a user id as google
    elsif  auth = Authentication.find_by_username_and_provider(omniauth['info']['email'], omniauth['provider'])
      auth.update(:provider => omniauth['provider'], :uid => omniauth['uid'], :username => omniauth['info']['email'].gsub(/\@gmail\.com/, ''))
      user = auth.user
      sign_in_and_redirect(:user, user)
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.email?
        if existing_user = User.find_by(:email => user.email)
          user = existing_user
          if user.authentications.where(:provider => omniauth['provider']).empty?
            user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'], :username => (omniauth['info']['nickname'].blank? ? omniauth['info']['email'] : omniauth['info']['nickname']))
          end
        end
        loop do
          existing = User.find_by(username: user.username)
          break if existing.nil?
          user.username = user.username + "-1"
        end
        user.skip_confirmation! 
        if user.save!
          # render status: 200, json: { email: user.email, authentication_token: user.authentication_token, id: user.id }
          sign_in_and_redirect(:user, user)
        else
          die
        end
      else
        die
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url
      end
    end
  end
    

  private
    
    def authentication_params
      params.require(:authentication).permit(:provider, :uid, :username)
    end
    
end
