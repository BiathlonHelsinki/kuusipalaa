class AddPinToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :pin, :string
  end
end
