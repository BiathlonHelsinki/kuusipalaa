class AddBlockchainTransactionToPledge < ActiveRecord::Migration[5.1]
  def change
    add_column :pledges, :blockchaintransaction_id, :integer, unique: true, index: true
  end
end
