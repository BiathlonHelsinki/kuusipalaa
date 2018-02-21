class AddOpentimeToInstances < ActiveRecord::Migration[5.1]
  def change
    add_column :instances, :open_time, :boolean
  end
end
