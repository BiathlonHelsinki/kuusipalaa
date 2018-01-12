class AddBookedByToStakes < ActiveRecord::Migration[5.1]
  def change
    add_column :stakes, :bookedby_id, :integer
  end
end
