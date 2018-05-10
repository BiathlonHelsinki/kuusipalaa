class Proposal < ApplicationRecord
  has_many :images, as: :item, :dependent => :destroy
  has_many :pledges, as: :item, :dependent => :destroy
  has_many :comments, as: :item, dependent: :destroy
  belongs_to :user
  has_one :event
  has_many :instances
  def proposer_type
    'User'
  end

  def proposer_id
    user_id
  end

  def proposer
    user
  end

  def root_comment
    self
  end


  def item
    self 
  end


end