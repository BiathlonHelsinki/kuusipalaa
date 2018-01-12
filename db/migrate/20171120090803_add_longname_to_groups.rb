class AddLongnameToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :long_name, :string
  end
end
