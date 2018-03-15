class Pledge < ApplicationRecord
  belongs_to :item, polymorphic: true, touch: true
  belongs_to :pledger, polymorphic: true
  has_many :activities, as: :item
  belongs_to :user
  after_save :update_activity_feed
  before_destroy :withdraw_activity
  validates_numericality_of :pledge, greater_than_or_equal_to: 0
  acts_as_paranoid
  validate :one_per_user
  validate :check_balance
  after_save :notify_item
  scope :unconverted, -> () { where('converted = 0 OR converted is null')}
  scope :converted, -> () { where(converted: true)}

  def comments  
    #  do not allow comments on specific pledges, that would be insane
    []
  end

  def contributor
    user
  end

  def max_for_user(user)
    item.max_for_user(user)
  end

  def notify_item
    item.notify_if_enough
  end

  def attachment?
    false
  end
  
  def image?
    false
  end

  def content_linked
    nil
  end
  
  def content
    comment
  end

  private


  def check_balance
    pledger.update_balance_from_blockchain
    if pledge < 0 || pledge > pledger.latest_balance
      errors.add(:pledge, 'You cannot pledge this amount.')
    end
  end
  
  def one_per_user
    unless item.pledges.where(pledger: pledger, converted: false).to_a.delete_if{|x| x == self}.empty?
      errors.add(:pledger, 'You have already pledged to this. Please edit your pledge.') 
    end
  end

  def update_activity_feed
    if created_at == updated_at
      # assume it's new
      Activity.create(user_id: user_id, item: self, description: "pledged_to", numerical_value: pledge, extra_info: pledge, addition: 0)
    else
      Activity.create(user: user, item: self, description: "edited_their_pledge_to", extra_info: pledge, addition: 0)
    end
    if item.class == Proposal
      item.update_column_caches
      item.save
    end

  end
  
  def withdraw_activity
    item.comments << Comment.create(user: user, content: "Pledge of #{pledge.to_s}#{ENV['currency_symbol']} withdrawn.",  systemflag: true)
    Activity.create(user: user, item: item, description: "withdrew_a_pledge", extra_info: "#{pledge.to_s}", addition: 0)
  end

end