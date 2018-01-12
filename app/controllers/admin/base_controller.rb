class Admin::BaseController < ApplicationController
  layout 'admin'
  before_action :force_english

  before_action :authenticate_user!
  before_action :authenticate_admin!

  def authenticate_admin!
    redirect_to root_path unless current_user.has_role? :admin
  end

  def check_permissions
    authorize! :create, resource
  end

  def force_english
    I18n.locale = 'en'
  end

  def home

  end

end
