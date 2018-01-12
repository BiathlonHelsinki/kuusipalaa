class Notification < ApplicationRecord
  belongs_to :item, polymorphic: true
  belongs_to :user
  
  
  scope :by_user, -> (user_id) { where(user_id: user_id) }
  
  validates_presence_of :user_id, :item_id, :item_type
end
