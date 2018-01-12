class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include CanCan::ControllerAdditions
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :get_locale
  before_action :get_era
  before_action :get_current_season

  protected

   def after_sign_in_path_for(resource)
     if session[:return_to]
       return session.delete(:return_to)
     else
       return '/'
     end
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
  end
  
  def get_era
    @era = Era.find(2)
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

end
