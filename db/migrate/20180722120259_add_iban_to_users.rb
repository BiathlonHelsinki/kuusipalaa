class AddIbanToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :iban, :string
    add_column :users, :other_bank_details, :string
  end
end
