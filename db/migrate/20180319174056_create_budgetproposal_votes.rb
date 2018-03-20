class CreateBudgetproposalVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :budgetproposal_votes do |t|
      t.references :voter, polymorphic: true
      t.references :budgetproposal, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :vote
      t.string :comment

      t.timestamps
    end
  end
end
