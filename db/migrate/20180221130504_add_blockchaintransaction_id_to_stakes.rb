class AddBlockchaintransactionIdToStakes < ActiveRecord::Migration[5.1]
  def change
    add_column :stakes, :blockchain_transaction_id, :integer
  end
end
