class BankstatementsController < ApplicationController

  before_action :authenticate_user!
  before_action :authenticate_stakeholder!
  before_action :authenticate_admin!, only: [:create, :destroy, :update, :edit, :new]

   def create
    @bankstatement = Bankstatement.new(bankstatement_params)
     if @bankstatement.save
      flash[:notice] = 'Bank statement saved.'
      redirect_to bankstatements_path
    else
      flash[:error] = "Error saving bank statement: " + @bankstatement.errors.inspect
      render template: 'bankstatements/new'
    end
  end

  def destroy
    bankstatement = Bankstatement.find(params[:id])
    bankstatement.destroy!
    redirect_to bankstatements_path
  end

  def edit
    @bankstatement = Bankstatement.find(params[:id])
  end

  def index
    @bankstatements = Bankstatement.order(updated_at: :desc)
    # @bankstatements += Comment.frontpage
    set_meta_tags title: t(:bank_statements)
  end

  def new
    @bankstatement = Bankstatement.new
  end

  def show
    @bankstatement = Bankstatement.find(params[:id])
    if cannot? :read, @bankstatement
      redirect_to bankstatements_path
    else
      set_meta_tags title: t(:bank_statements)
    end
  end



  def update
    @bankstatement = Bankstatement.find(params[:id])
    if @bankstatement.update_attributes(bankstatement_params)
      flash[:notice] = 'Bank statement details updated.'
      redirect_to bankstatements_path
    else
      flash[:error] = 'Error updating bank statement'
    end
  end

  protected

  def bankstatement_params
    params.require(:bankstatement).permit( :month, :year, :pdf)
  end

end