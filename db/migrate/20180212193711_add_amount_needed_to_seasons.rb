class AddAmountNeededToSeasons < ActiveRecord::Migration[5.1]
  def change
    add_column :seasons, :amount_needed, :integer
  end
end
