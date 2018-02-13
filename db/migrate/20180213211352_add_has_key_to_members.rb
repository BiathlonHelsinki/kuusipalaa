class AddHasKeyToMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :has_key, :boolean, null: false, default: false
  end
end
