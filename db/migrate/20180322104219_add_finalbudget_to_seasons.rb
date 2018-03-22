class AddFinalbudgetToSeasons < ActiveRecord::Migration[5.1]
  def change
    add_column :seasons, :final_budget, :boolean, default: false, null: false
  end
end
