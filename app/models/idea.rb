class Idea < ApplicationRecord
  has_many :pledges, as: :item
  belongs_to :user
  belongs_to :converted, polymorphic: true, optional: true
  belongs_to :proposer, polymorphic: true, optional: true
  belongs_to :parent, polymorphic: true, optional: true
  belongs_to :proposalstatus, optional: true
  belongs_to :ideatype
  has_many :additionaltimes, as: :item
  has_many :comments, as: :item
  validates :ideatype, :proposer_type, :proposer_id, :presence => true, :if => :active_or_find_type? 
  validates :name, :short_description, :proposal_text,  presence: true, if: :active_or_name_and_info?
  validates :timeslot_undetermined, inclusion: { in: [ true, false ]}, if: :active_or_when?
  validates :start_at, :end_at, presence: true, if: :determined_time?
  validates :points_needed, :price_public, presence: true, if: :active_or_points?
  validates :slug, presence: true, if: :active?
  accepts_nested_attributes_for :additionaltimes, reject_if: proc {|x| x['start_at'].blank? || x['end_at'].blank? }, allow_destroy: true

  has_many :activities, as: :item
  has_many :notifications, as: :item
  
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  mount_uploader :image, ImageUploader
  before_save :update_image_attributes

  scope :active, ->() { where(status: 'active')}
  scope :needing_to_be_published,  ->() { where(notified: :true).where(converted_id: nil)}

  def add_to_activity_feed
    if active?
      Activity.create(user: user, item: self, description: ideatype_id == 3 ? 'requested' : 'proposed')
    end
  end

  def active_or_find_type?
    status.include?('find_type') || active? && ideatype_id != 4
  end

  def active_or_when?
    status.include?('when') || active?
  end

  def active_or_points?
    status.include?('points') || active?
  end

  def determined_time?
    (timeslot_undetermined == false && !timeslot_undetermined.nil? ) && ideatype_id == 1
  end

  def active_or_name_and_info?
    status.include?('name_and_info') || active?
  end

  def should_generate_new_friendly_id?
    active?
  end

  def has_enough?
    pledged >= points_needed
  end

  def active?
    status == 'active'
  end

  def start_at_date
    start_at.nil? ? nil : start_at.strftime('%Y-%m-%d')
  end

  def end_at_date
    end_at.nil? ? nil : end_at.strftime('%Y-%m-%d')
  end

  def points_still_needed
    points_needed -  pledges.select(&:persisted?).sum(&:pledge)  
  end

  def points_still_needed_except(pledge)
    points_needed - pledges.select(&:persisted?).select{|x| x != pledge}.sum(&:pledge)
  end

  def max_for_user(user, pledge)
    [user.latest_balance, (points_needed * 0.9), pledges.select(&:persisted?).map(&:user).uniq.size >= 2 ? points_still_needed_except(pledge) : points_still_needed_except(pledge) -1 ].min.to_i
  end

  def pledged
    pledges.select(&:persisted?).sum(&:pledge)
  end

  def proposers
    if proposer_type == Group
      [user, proposer.members.map(&:user)].uniq
    else
      [user]
    end
  end
  
  def notify_if_enough

    if pledged >= points_needed
      if notified != true
        begin
          IdeaMailer.proposal_for_review(self).deliver_now
          update_attribute(:notified, true)
        rescue
          die
          notified = false
        end
      end
    end
  end

  private

  def update_image_attributes

    if image.present? && image?

      if image.file.exists?
        self.image_content_type = image.file.content_type
        self.image_size = image.file.size
        self.image_width, self.image_height = `identify -format "%wx%h" #{image.file.path}`.split(/x/) rescue nil
      end
    end
  end

end
