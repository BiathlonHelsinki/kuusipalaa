class CreateAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :answers do |t|
      t.references :question, foreign_key: true

      t.timestamps
    end
    Answer.create_translation_table! body: :text
  end
end
