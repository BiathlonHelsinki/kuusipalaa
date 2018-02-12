class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include CanCan::ControllerAdditions
  before_action :check_service_status
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :get_locale
  before_action :get_era
  before_action :get_current_season
  before_action :store_user_location!, if: :storable_location?

  protected

  def after_sign_in_path_for(resource)
    
    stored_location_for(resource) || request.env['omniauth.origin'] ||  root_path
  end

  def check_service_status
    @parity_status = Net::Ping::TCP.new(ENV['parity_server'],  ENV['parity_port'], 1).ping?
    @geth_status = Net::Ping::TCP.new(ENV['geth_server'],  ENV['geth_port'], 1).ping?
    @api_status = Net::Ping::TCP.new(ENV['biathlon_api_server'],  ENV['biathlon_api_port'], 1).ping?
    @dapp_status = Net::Ping::TCP.new(ENV['dapp_server'], ENV['dapp_port'], 1).ping?
    
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

  def fill_collection
    @collection_options = []
    @collection_options << [current_user.name, current_user.id, 'User', nil, 50, false]
    last = ''
    unless current_user.members.empty?
      current_user.members.each do |m|
        if m.access_level >= KuusiPalaa::Access::ADMIN
          if @group
            if m.source == @group
              last = [m.source.long_name.blank? ? m.source.name : m.source.long_name, m.source.id, 'Group', nil, m.source.stake_price, m.source.charge_vat?.to_s]
            else
              @collection_options << [m.source.long_name.blank? ? m.source.name : m.source.long_name, m.source.id, 'Group', nil,  m.source.stake_price, m.source.charge_vat?.to_s]
            end
          else
            @collection_options << [m.source.name, m.source.id, 'Group']
          end

        else

          @collection_options << [m.source.name + t(:only_owners_can_buy), m.source.id, 'Group', 'disabled']
        end
      end
    end
    unless last.blank?
      @collection_options.unshift(last)
    end
  end
end
