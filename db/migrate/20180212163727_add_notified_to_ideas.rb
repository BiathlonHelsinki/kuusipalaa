class AddNotifiedToIdeas < ActiveRecord::Migration[5.1]
  def change
    add_column :ideas, :notified, :boolean
  end
end
