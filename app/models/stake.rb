class Stake < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :season
  belongs_to :bookedby, class_name: 'User'
  mount_uploader :invoice, AttachmentUploader

  scope :paid, ->() { where(paid: true)}
  scope :booked_unpaid,  ->() { where('paid is not true')}
end
