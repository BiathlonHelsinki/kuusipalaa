class AddContributorToQuestions < ActiveRecord::Migration[5.1]
  def change
    add_reference :questions, :contributor, polymorphic: true
  end
end
