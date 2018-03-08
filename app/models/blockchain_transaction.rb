class BlockchainTransaction < ApplicationRecord
  belongs_to :transaction_type
  belongs_to :account
  belongs_to :recipient, class_name: 'Account', foreign_key: 'recipient_id'
  belongs_to :ethtransaction
  has_one :stake
  has_one :activity, dependent: :destroy
end
