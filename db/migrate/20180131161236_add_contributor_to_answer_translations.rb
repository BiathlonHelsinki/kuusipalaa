class AddContributorToAnswerTranslations < ActiveRecord::Migration[5.1]
  def change
    add_reference :answer_translations, :contributor, polymorphic: true, index: {name: 'contributor_answer_index' }
  end
end
