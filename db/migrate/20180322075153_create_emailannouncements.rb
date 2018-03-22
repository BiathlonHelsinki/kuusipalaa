class CreateEmailannouncements < ActiveRecord::Migration[5.1]
  def change
    create_table :emailannouncements do |t|
      t.references :announcer, polymorphic: true
      t.references :user, foreign_key: true
      t.references :reference, polymorphic: true
      t.references :email, foreign_key: true
      t.boolean :only_stakeholders
      t.text :message
      t.boolean :published
      t.string :subject

      t.timestamps
    end
  end
end
