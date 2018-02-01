class AddUserIdToQuestions < ActiveRecord::Migration[5.1]
  def change
    add_reference :questions, :user, foreign_key: true
    add_reference :answers, :user, foreign_key: true
  end
end
