class AddLatestBalanceToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :latest_balance, :integer, null: false, default: 0
  end
end
