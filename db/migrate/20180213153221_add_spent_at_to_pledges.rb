class AddSpentAtToPledges < ActiveRecord::Migration[5.1]
  def change
    add_column :pledges, :spent_at, :datetime
  end
end
