class AddUniqueToBudgetproposalvotes < ActiveRecord::Migration[5.1]
  def change
    add_index :budgetproposal_votes,  [:budgetproposal_id, :voter_id, :voter_type], unique: true, name: :one_vote_index
  end
end
