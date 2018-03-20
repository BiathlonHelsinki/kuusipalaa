class BudgetproposalVote < ApplicationRecord
  belongs_to :voter, polymorphic: true
  belongs_to :budgetproposal
  belongs_to :user
  has_many :activities, as: :item

  after_save :update_activity_feed

  def item
    budgetproposal
  end

  def comments
    budgetproposal.comments
  end

  def update_activity_feed
    if created_at == updated_at
      # assume it's new
      Activity.create(user_id: user_id, contributor: voter, item: budgetproposal, description: "voted_on", addition: 0)
    else
      Activity.create(user: user, item: budgetproposal, contributor: voter, description: "changed_their_vote_on", addition: 0)
    end
   
  end

end
