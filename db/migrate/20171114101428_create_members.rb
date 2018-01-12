class CreateMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :members do |t|
      t.references :source, polymorphic: true
      t.references :user, foreign_key: true
      t.integer :access_level
      t.integer :notification_level

      t.timestamps
    end
  end
end
