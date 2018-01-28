class CreateGroupsRoles < ActiveRecord::Migration[5.1]
  def change

    create_table(:groups_roles, :id => false) do |t|
      t.references :group
      t.references :role
    end

    add_index(:groups_roles, [ :group_id, :role_id ])
  end
end
