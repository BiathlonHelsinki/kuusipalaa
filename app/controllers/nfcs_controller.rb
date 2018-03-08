class NfcsController < ApplicationController

  before_action :authenticate_user!

  def destroy
    @nfc = Nfc.find(params[:id])
    if can? :destroy, @nfc
      @nfc.destroy
      flash[:notice] = t(:card_deleted)
    end
    redirect_to user_nfcs_path(@nfc.user)
  end

  def index
    @user = User.friendly.find(params[:user_id])
    if current_user != @user && !current_user.has_role?(:admin) 
      flash[:error] = t(:not_your_cards)
      redirect_to current_user
    end
    set_meta_tags title: t(:id_cards)
  end

  def toggle_key
    @nfc = Nfc.find(params[:id])
    if can?(:edit, @nfc) && @nfc.user.gets_key?
      was = @nfc.keyholder
      @nfc.user.nfcs.each {|x| x.update_column(:keyholder, false) }
      @nfc.update_column(:keyholder, !was)
      flash[:notice] = t(:key_updated)
    else

      flash[:error] = t(:generic_error)
    end
    redirect_to user_nfcs_path(@nfc.user)
  end

end