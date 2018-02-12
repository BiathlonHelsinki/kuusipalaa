class AddThingSizeToIdeas < ActiveRecord::Migration[5.1]
  def change
    add_column :ideas, :thing_size, :integer
  end
end
