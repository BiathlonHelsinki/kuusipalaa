class AddBlockchainTransactionToRsvps < ActiveRecord::Migration[5.1]
  def change
    add_column :rsvps, :blockchain_transaction_id, :integer, unique: true, index: true

  end
end
