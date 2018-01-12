class AddAvatartmpToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :avatar_tmp, :string
    add_column :groups, :avatar_tmp, :string
  end
end
