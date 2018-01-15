class AddPriceToStakes < ActiveRecord::Migration[5.1]
  def change
    add_column :stakes, :price, :float, null: false, default: 50.0
  end
end
