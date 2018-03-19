class BudgetProposal < ApplicationRecord
  belongs_to :season
  belongs_to :proposer, polymorphic: true
  belongs_to :user
  validates_presence_of :season_id, :user_id, :name, :description, :amount
  validates :proposer, presence: true
  has_many :comments, as: :item
  has_many :activities, as: :item, dependent: :destroy
  has_many :budgetproposal_votes
end
