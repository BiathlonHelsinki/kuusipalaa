class AddEthtransactionToStakes < ActiveRecord::Migration[5.1]
  def change
    add_reference :stakes, :ethtransaction, foreign_key: true
  end
end
