class AddHoursEstimateToIdeas < ActiveRecord::Migration[5.1]
  def change
    add_column :ideas, :hours_estimate, :integer
  end
end
