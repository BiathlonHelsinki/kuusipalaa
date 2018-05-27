class TransactionType < ApplicationRecord
  validates_presence_of :name
  has_many :ethtransactions
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]
end
