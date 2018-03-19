class AddHasPhysicalKeyToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :has_physical_key, :boolean, default: false, null: false
  end
end
