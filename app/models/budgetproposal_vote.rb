class BudgetproposalVote < ApplicationRecord
  belongs_to :voter, polymorphic: true
  belongs_to :budget_proposal
  belongs_to :user
end
