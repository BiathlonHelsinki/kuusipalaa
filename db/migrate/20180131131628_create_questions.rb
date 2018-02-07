class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.string :slug
      t.references :page, foreign_key: true
      t.references :era, foreign_key: true

      t.timestamps
    end
    Question.create_translation_table! question: :string
  end
end
