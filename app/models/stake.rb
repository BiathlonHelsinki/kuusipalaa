class Stake < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :season
  belongs_to :bookedby, class_name: 'User'
  mount_uploader :invoice, AttachmentUploader
  mount_uploader :paidconfirmation, AttachmentUploader

  validates_presence_of :owner_id, :season_id, :bookedby_id

  scope :by_season, -> (x) { where(season_id: x)}
  scope :paid, ->() { where(paid: true)}
  scope :booked_unpaid,  ->() { where('paid is not true')}
  
end
