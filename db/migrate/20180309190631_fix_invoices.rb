class FixInvoices < ActiveRecord::Migration[5.1]
  def change
    Stake.all.each do |stake|
      stake.update_column(:invoice_due, stake.created_at + 2.weeks)
    end
  end
end
