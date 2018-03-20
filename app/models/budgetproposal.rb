class Budgetproposal < ApplicationRecord
  belongs_to :season
  belongs_to :proposer, polymorphic: true
  belongs_to :user
  validates_presence_of :season_id, :user_id, :name, :description, :amount
  validates :proposer, presence: true
  has_many :comments, as: :item
  has_many :activities, as: :item, dependent: :destroy
  has_many :budgetproposal_votes
  has_many :notifications, as: :item
  before_validation :smart_add_url_protocol


  after_create :update_activity_feed

  def discussion
    [budgetproposal_votes, comments].flatten.delete_if{|x| !x.persisted? }.sort_by(&:created_at)
  end

  def root_comment
    self
  end

  def update_activity_feed
    if created_at == updated_at
      # assume it's new
      Activity.create(user_id: user_id, contributor: proposer, item: self, description: "proposed_for_the_budget", addition: 0)
    else
      Activity.create(user: user, item: self, contributor: proposer, description: "edited_their_budget_proposal", addition: 0)
    end
   
  end

  protected

  def smart_add_url_protocol
    unless self.link[/\Ahttp:\/\//] || self.link[/\Ahttps:\/\//]
      self.link = "http://#{self.link}"
    end
  end
end
