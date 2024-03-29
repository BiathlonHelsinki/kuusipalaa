class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  include CanCan::ControllerAdditions
  before_action :check_service_status
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :get_locale
  before_action :get_era
  before_action :get_current_season
  before_action :store_user_location!, if: :storable_location?
  before_action :get_pending_kuusipalaa #, if: :user_signed_in?
  before_action :fill_collection, if: :user_signed_in?
  before_action :are_we_open?
  before_action :check_pin, if: :user_signed_in?
  before_action :check_consents, if: :user_signed_in?
  before_action :check_alerts, if: :user_signed_in?
  before_action :check_refund, if: :user_signed_in?
  self.page_cache_directory = :locale_cache_directory

  def clear_idcard_info
    authenticate_user!
    current_user.update_column(:saw_idcard_info, true)
    render(js: '$("#idcard_info").fadeOut();')
  end

  protected

  rescue_from CanCan::AccessDenied do |_exception|
    flash[:error] = t(:generic_error)
    redirect_to '/'
  end

  def after_sign_in_path_for(resource)
    session[:return_to] = nil
    stored_location_for(resource) || request.env['omniauth.origin'] || root_path
  end

  def check_alerts
    return if current_user.saw_idcard_info == true
    @show_idcard_info = true
  end

  def check_consents
    return if controller_path == 'users' || controller_path == 'devise/sessions'
    return unless current_user.opt_in_weekly_newsletter.nil? || current_user.accepted_tos.nil?
    save_location
    redirect_to(consent_user_path(current_user))
  end

  def check_service_status
    @parity_status = Net::Ping::TCP.new(ENV['parity_server'], ENV['parity_port'], 1).ping?
    @geth_status = Net::Ping::TCP.new(ENV['geth_server'], ENV['geth_port'], 1).ping?
    @api_status = Net::Ping::TCP.new(ENV['biathlon_api_server'], ENV['biathlon_api_port'], 1).ping?
    @dapp_status = Net::Ping::TCP.new(ENV['dapp_server'], ENV['dapp_port'], 1).ping?
  end

  def check_pin
    return if action_name == 'consent'
    return unless current_user.saw_idcard_info == true
    @needs_pin = current_user.pin.blank?
  end

  def check_refund
    return unless current_user.refund_pending?
    @refund_pending = true
  end

  def configure_permitted_parameters
    added_attrs = %i[username email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: added_attrs)
  end

  def save_location
    session[:return_to] = request.fullpath
  end

  def get_pending_kuusipalaa
    @kuusipalaa_pending = []
    Idea.needing_to_be_published.each do |pending|
      @kuusipalaa_pending.push([:has_enough_ready_to_be, pending]) if pending.proposers.flatten.uniq.include?(current_user)
    end
  end

  def get_current_season
    @current_season = Season.find(1)
    @next_season = begin
      Season.find(2)
    rescue StandardError
      "2"
    end
  end

  def get_era
    @era = Era.find(3)
  end

  def get_locale
    session[:locale] = params[:locale] if params[:locale] && %w[en fi].include?(params[:locale])

    if session[:locale].blank?
      available = %w{en fi}
      I18n.locale = http_accept_language.compatible_language_from(available)
      session[:locale] = I18n.locale
    else
      I18n.locale = session[:locale]
    end
    fallbacks = { en: [:en], fi: [:fi] }
    I18n.fallbacks = fallbacks[I18n.locale]
  end

  private

  def are_we_open?
    return if request.xhr?
    Opensession.uncached do
      sesh = Opensession.by_node(1).find_by(closed_at: nil)
    end
    sesh = Opensession.by_node(1).find_by(closed_at: nil)
    @kp_is_open = if sesh.nil?
      false
    else
      true
    end
  end

  def authenticate_admin!
    redirect_to(root_path) unless current_user.has_role?(:admin)
  end

  def authenticate_stakeholder!
    if user_signed_in?
      redirect_to(root_path) unless current_user.is_stakeholder?
    else
      redirect_to(root_path)
    end
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? && request.path !~ /callback$/
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  def fill_stake_collection
    @stake_collection = []
    @stake_collection << [current_user.name + " (#{current_user.stakes.paid.sum(&:amount)} #{t(:stake, count: current_user.stakes.paid.sum(&:amount))})", current_user.id, 'User', nil, current_user.stakes.paid.sum(&:amount), false] if current_user.is_stakeholder?
    last = ''
    return if current_user.members.empty?
    current_user.members.each do |m|
      if m.access_level >= KuusiPalaa::Access::ADMIN
        next unless m.source.is_stakeholder?
        @stake_collection << [m.source.name + " (#{m.source.stakes.paid.sum(&:amount)} #{t(:stake, count: m.source.stakes.paid.sum(&:amount))})", m.source.id, 'Group', nil, m.source.stakes.paid.sum(&:amount), false]
      end
    end

    # unless last.blank?
    #   @collection_options.unshift(last)
    # end
  end

  def fill_collection
    @collection_options = []
    @collection_options << [current_user.name.to_s + " (#{current_user.available_balance.to_i}ᵽ)", current_user.id, 'User', nil, 50, false]
    last = ''
    unless current_user.members.empty?
      current_user.members.each do |m|
        if m.access_level >= KuusiPalaa::Access::ADMIN
          if @group
            if m.source == @group
              last = [m.source.long_name.blank? ? m.source.name + " (#{m.source.available_balance}ᵽ)" : m.source.long_name + " (#{m.source.available_balance}ᵽ)", m.source.id, 'Group', nil, m.source.stake_price, m.source.charge_vat?.to_s]
            else
              @collection_options << [m.source.long_name.blank? ? m.source.name + " (#{m.source.available_balance}ᵽ)" : m.source.long_name + " (#{m.source.available_balance}ᵽ)", m.source.id, 'Group', nil, m.source.stake_price, m.source.charge_vat?.to_s]
            end
          else
            @collection_options << [m.source.name + " (#{m.source.available_balance}ᵽ)", m.source.id, 'Group']
          end

        else

          @collection_options << [m.source.name + t(:only_owners_can_buy), m.source.id, 'Group', 'disabled']
        end
      end
    end
    return if last.blank?
    @collection_options.unshift(last)
  end

  def locale_cache_directory
    page = params[:page]&.to_s || "1"
    Rails.public_path.join('cache', I18n.locale.to_s, page)
  end
end
