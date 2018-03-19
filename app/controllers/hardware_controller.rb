class HardwareController < ApplicationController

  before_action :authenticate_user!
  before_action :authenticate_stakeholder!

  def index
    @hardware = Hardware.where(checkable: true)
    @physical_keyholders = User.where(has_physical_key: true)
  end

end