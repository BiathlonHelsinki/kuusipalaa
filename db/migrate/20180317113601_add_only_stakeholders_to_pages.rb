class AddOnlyStakeholdersToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :only_stakeholders, :boolean, null: false, default: false
    add_column :posts, :only_stakeholders, :boolean, null: false, default: false
  end
end
