class AddHidefFromFrontToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :hide_from_front, :boolean
  end
end
