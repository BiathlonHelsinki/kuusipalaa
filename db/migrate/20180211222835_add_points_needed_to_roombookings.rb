class AddPointsNeededToRoombookings < ActiveRecord::Migration[5.1]
  def change
    add_column :roombookings, :points_needed, :integer
    change_column :roombookings, :rate_id, :integer, :null => true
    change_column :roombookings, :day, :date, unique: false
  end
end
