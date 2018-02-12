class AddPOiddPointsNeededToIdeas < ActiveRecord::Migration[5.1]
  def change
    add_column :ideas, :points_needed, :integer
  end
end
