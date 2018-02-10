class AddStatusToIdeas < ActiveRecord::Migration[5.1]
  def change
    add_column :ideas, :status, :string
  end
end
