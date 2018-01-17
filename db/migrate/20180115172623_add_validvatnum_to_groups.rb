class AddValidvatnumToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :valid_vat_number, :boolean
  end
end
