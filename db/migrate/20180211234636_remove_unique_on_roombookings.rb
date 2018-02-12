class RemoveUniqueOnRoombookings < ActiveRecord::Migration[5.1]
  def change
    remove_index :roombookings, :day
    add_index :roombookings, :day
  end
end
