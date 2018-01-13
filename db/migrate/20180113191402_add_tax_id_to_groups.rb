class AddTaxIdToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :taxid, :string
    add_column :groups, :is_member, :boolean, default: false, null: false
    add_column :groups, :contact_phone, :string
    add_column :users, :contact_phone, :string
  end
end
