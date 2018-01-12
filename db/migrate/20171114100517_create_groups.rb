class CreateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.boolean :active
      t.text :description
      t.string :avatar
      t.string :avatar_content_type
      t.integer :avatar_size
      t.integer :avatar_width
      t.integer :avatar_height
      t.string :slug
      t.string :website
      t.string :twitter_name
      t.string :geth_pwd

      t.timestamps
    end
  end
end
