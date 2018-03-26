class Email < ApplicationRecord
  extend FriendlyId
  friendly_id :subject , :use => [ :slugged, :finders, :history]
  has_many :emailannouncements  
  validates_presence_of :subject, :body
  
  scope :published, -> () { where('sent_at is not null') }
  scope :unsent, -> () { where('sent is not true') }
  scope :sent, -> () { where(sent: true) }
  
  def feed_date
    sent_at.nil? ? updated_at : sent_at
  end
  
end
