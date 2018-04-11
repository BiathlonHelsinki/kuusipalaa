class Userphoto < ApplicationRecord
  belongs_to :instance
  belongs_to :user
  after_create :update_activity_feed
  before_destroy :withdraw_activity
  has_one :userphotoslot
  has_many :comments, as: :item
  scope :by_user, ->(user_id) { where(user_id: user_id) }
 
  mount_uploader :image, ImageUploader
  
  def update_activity_feed
    if created_at == updated_at
      # assume it's new
      Activity.create(user: user, contributor: user, item: self.instance, description: "shared_an_image_from", extra: self, addition: 0)
    end

  end
  
  def withdraw_activity
    Activity.create(user: user, contributor: user, item: self.instance, description: "removed_a_shared_image", addition: 0)
  end
  
  def item
    instance
  end


end
