class AddStartatToRoombookings < ActiveRecord::Migration[5.1]
  def change
    add_column :roombookings, :start_at, :datetime
    add_column :roombookings, :end_at, :datetime
    add_reference :roombookings, :booker, polymorphic: true
  end
end
