class AddImageToIdeas < ActiveRecord::Migration[5.1]
  def change
    add_column :ideas, :image, :string
    add_column :ideas, :image_size, :integer, length: 8
    add_column :ideas, :image_content_type, :string
    add_column :ideas, :image_updated_at, :datetime
    add_column :ideas, :image_width, :integer
    add_column :ideas, :image_height, :integer
  end
end
