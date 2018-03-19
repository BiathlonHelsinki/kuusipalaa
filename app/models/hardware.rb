class Hardware < ApplicationRecord
  devise :rememberable
  belongs_to :hardwaretype
  acts_as_token_authenticatable
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders ]
  validates_presence_of :name
  validates_uniqueness_of :name
  
  scope :monitored, ->() { where(checkable: true)}
  def checkable?
    checkable
  end
  
end
