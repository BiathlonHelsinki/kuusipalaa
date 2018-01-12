class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include CanCan::ControllerAdditions
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :get_locale
  before_action :get_era
  before_action :get_current_season
  before_action :store_user_location!, if: :storable_location?

  protected

  def after_sign_in_path_for(resource)
    
    stored_location_for(resource) || request.env['omniauth.origin'] ||  root_path
  end


  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs

  end

  def save_location
    session[:return_to] = request.fullpath
  end

  def get_current_season
    @current_season = Season.order(start_at: :desc).last
    @next_season = Season.count == 1 ? @current_season : 2
  end

  def get_era
    @era = Era.find(3)
  end

  def get_locale

    if params[:locale]
      session[:locale] = params[:locale]
    end

    if session[:locale].blank?
      available  = %w{en fi}
      I18n.locale = http_accept_language.compatible_language_from(available)
      session[:locale] = I18n.locale
    else
      I18n.locale = session[:locale]
    end

  end

  private

  def storable_location?

    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? && request.path !~ /callback$/
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)

  end

end
