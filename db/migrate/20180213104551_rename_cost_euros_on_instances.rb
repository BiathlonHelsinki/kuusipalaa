class RenameCostEurosOnInstances < ActiveRecord::Migration[5.1]
  def change
    rename_column :instances, :cost_euros, :price_public
    rename_column :instances, :cost_stakeholders, :price_stakeholders
  end
end
