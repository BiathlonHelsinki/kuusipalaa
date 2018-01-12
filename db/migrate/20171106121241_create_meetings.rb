class CreateMeetings < ActiveRecord::Migration[5.1]
  def change
    create_table :meetings do |t|
      t.references :place, foreign_key: true
      t.datetime :start_at
      t.datetime :end_at
      t.references :era, foreign_key: true
      t.string :image
      t.string :image_content_type
      t.integer :image_size, length: 8
      t.integer :image_width
      t.integer :image_height
      t.string :slug
      t.boolean :published
      t.boolean :cancelled
      t.timestamps
    end
    Meeting.create_translation_table! name: :string, description: :text
  end
end
