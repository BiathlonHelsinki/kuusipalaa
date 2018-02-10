class AddRoomneededToIdeas < ActiveRecord::Migration[5.1]
  def change
    add_column :ideas, :room_needed, :integer
    add_column :ideas, :allow_others, :boolean
    add_column :ideas, :price_public, :float
    add_column :ideas, :price_stakeholders, :float
  end
end
