class AddInvoiceAmountToStakes < ActiveRecord::Migration[5.1]
  def change
    add_column :stakes, :invoice_amount, :float
  end
end
