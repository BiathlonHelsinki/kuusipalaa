class AddCostStakeholdersToInstances < ActiveRecord::Migration[5.0]
  def change
    add_column :instances, :cost_stakeholders, :float
    add_column :instances, :room_needed, :integer
    add_column :instances, :allow_others, :boolean
  end
end
