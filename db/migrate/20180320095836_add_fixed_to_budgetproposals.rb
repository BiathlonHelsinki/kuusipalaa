class AddFixedToBudgetproposals < ActiveRecord::Migration[5.1]
  def change
    add_column :budgetproposals, :fixed, :boolean, default: false, null: false
  end
end
