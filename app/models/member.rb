class Member < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :user
  validates_uniqueness_of :user_id, message: 'is already part of this group.',  scope: [:source_type, :source_id]
  has_many :activities, as: :item
  after_create :add_to_activity_feed

  def add_to_activity_feed
    Activity.create(user: self.user, item: self.source, description: "was_added_to_the_group",  addition: 0)
  end

  def username
    user.nil? ? nil : user.username
  end

end
