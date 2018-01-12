class ChangeNullOnInstances < ActiveRecord::Migration[5.1]
  def change
    change_column :rsvps, :instance_id, :integer, :null => true
  end
end
