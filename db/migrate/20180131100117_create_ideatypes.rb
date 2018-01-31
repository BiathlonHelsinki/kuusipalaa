class CreateIdeatypes < ActiveRecord::Migration[5.1]
  def change
    create_table :ideatypes do |t|
      t.string :slug

      t.timestamps
    end
    Ideatype.create_translation_table! name: :string, description: :text
  end
end
