class Admin::ExpensesController < Admin::BaseController


  def create
    @expense = Expense.new(expense_params)
    if @expense.save
      flash[:notice] = 'Expense saved.'
      redirect_to admin_expenses_path
    else
      flash[:error] = "Error saving expense: " + @expense.errors.inspect
      render template: 'admin/expenses/new'
    end
  end

  def destroy
    expense = Expense.friendly.find(params[:id])
    expense.destroy!
    redirect_to admin_expenses_path
  end

  def edit
    @expense = Expense.friendly.find(params[:id])
  end

  def index
    @expenses = Expense.order(created_at: :asc)
    set_meta_tags title: 'News'
  end

  def new
    @expense = Expense.new
  end

  def update
    @expense = Expense.friendly.find(params[:id])
    if @expense.update_attributes(expense_params)
      flash[:notice] = 'Expense details updated.'
      redirect_to admin_expenses_path
    else
      flash[:error] = 'Error updating expense'
    end
  end

  protected

    def expense_params
      params.require(:expense).permit(:recipient, :date_spent, :description, :amount, :alv, :receipt, :notes)
    end

end
