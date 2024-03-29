class Idea < ApplicationRecord
  has_many :pledges, as: :item
  belongs_to :user
  has_many :events
  belongs_to :converted, polymorphic: true, optional: true
  belongs_to :proposer, polymorphic: true, optional: true
  belongs_to :parent, polymorphic: true, optional: true
  belongs_to :proposalstatus, optional: true
  belongs_to :ideatype
  has_many :additionaltimes, as: :item
  has_many :comments, as: :item, dependent: :destroy
  validates :ideatype, :proposer_type, :proposer_id, presence: true, if: :active_or_find_type?
  validates :name, :short_description, :proposal_text, presence: true, if: :active_or_name_and_info?
  # validates :timeslot_undetermined, inclusion: { in: [ true, false ]}, if: :active_or_when?
  validates :start_at, :end_at, presence: true, if: :determined_time?
  validates :points_needed,  presence: true, if: :active_or_points?
  validates :slug, presence: true, if: :active?
  # after_commit :notify_if_enough
  accepts_nested_attributes_for :additionaltimes, reject_if: proc { |x| x['start_at'].blank? || x['end_at'].blank? }, allow_destroy: true

  has_many :activities, as: :item
  has_many :notifications, as: :item

  extend FriendlyId
  friendly_id :name, use: %i[slugged history finders]

  mount_uploader :image, ImageUploader
  before_save :announce_cancellation, if: :cancelled?
  before_save :update_image_attributes, if: :active_or_name_and_info?
  # before_commit :add_to_activity_feed, if: :active?
  scope :between, ->(start_time, end_time) {
    where(["(start_at >= ?  AND  end_at <= ?) OR ( start_at >= ? AND end_at <= ? ) OR (start_at >= ? AND start_at <= ?)  OR (start_at < ? AND end_at > ? )",
           start_time.to_date.at_midnight.to_s, end_time.to_date.end_of_day.to_fs(:db), start_time.to_date.at_midnight.to_s, end_time.to_date.end_of_day.to_fs(:db),
           start_time.to_date.at_midnight.to_s, end_time.to_date.end_of_day.to_fs(:db), start_time.to_date.at_midnight.to_s, end_time.to_date.end_of_day.to_fs(:db)])
  }
  scope :timed, -> { where(timeslot_undetermined: false) }
  scope :active, -> { where(status: 'active') }
  scope :back_room, -> { where("room_needed in (2,3)") }
  scope :needing_to_be_published, -> { where(notified: :true).where(converted_id: nil).where("status = 'active'") }
  scope :converted, -> { where.not(converted_id: nil) }
  scope :unconverted, -> { where(converted_id: nil) }

  def as_json(_options = {})
    {
      id: id,
      title: name,
      description: short_description || "",
      start: calendar_start_at.nil? ? nil : calendar_start_at.localtime.strftime('%Y-%m-%d %H:%M:00'),
      end: end_at.nil? ? nil : end_at.localtime.strftime('%Y-%m-%d %H:%M:00'),
      allDay: false,
      recurring: false,
      temps: points_needed,
      class: 'proposal',
      url: Rails.application.routes.url_helpers.idea_path(slug)
    }
  end

  def announce_cancellation
    return unless status == 'cancelled' && status_changed?
    comments << Comment.create(user: user, contributor: user, content: "this_proposal_has_been_cancelled", systemflag: true)
    Activity.create(user: user, contributor: user, item: self, description: "cancelled_proposal", extra_info: cancel_reason)
  end

  def item
    self
  end

  def cancel_pledges
    pledges.each do |p|
      p.cancel_activity
      p.delete
    end
  end

  def calendar_start_at
    start_at - 1.hour
  end

  def converted?
    !events.empty? || status == 'converted'
  end

  def root_comment
    self
  end

  def discussion
    [pledges, comments].flatten.compact
  end

  def description
    proposal_text
  end

  def add_to_activity_feed
    return unless status == 'active'
    return unless Activity.last.item != self
    Activity.create(user: user, contributor: proposer, item: self, description: ideatype_id == 3 ? 'requested' : 'proposed')
  end

  def active_or_find_type?
    status.include?('find_type') || (active? && ideatype_id != 4)
  end

  def active_or_when?
    status.include?('when') || active?
  end

  def active_or_points?
    status.include?('points') || active?
  end

  def determined_time?
    (timeslot_undetermined == false && !timeslot_undetermined.nil?) && ideatype_id == 1 && (status.include?('points') || active?)
  end

  def active_or_name_and_info?
    status.include?('name_and_info') || active?
  end

  def should_generate_new_friendly_id?
    active?
  end

  def has_enough?
    active? && (pledged.to_i >= points_needed.to_i)
  end

  def draught?
    !active? && !cancelled?
  end

  def cancelled?
    status == 'cancelled'
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
    points_needed - pledges.select(&:persisted?).sum(&:pledge)
  end

  def points_still_needed_except(pledge)
    points_needed - pledges.select(&:persisted?).select { |x| x != pledge }.sum(&:pledge)
  end

  def max_for_user(pledger, pledge)
    [pledger.available_balance, (points_needed * 0.9), if pledges.select(&:persisted?).map(&:pledger).delete_if { |x| x.all_peers.include?(pledger) }.uniq.size >= 2
                                                         points_still_needed_except(pledge)
                                                       else
                                                         points_still_needed_except(pledge) - 1
                                                       end].min.to_i
  end

  def pledged
    pledges.select(&:persisted?).sum(&:pledge)
  end

  def proposers
    if proposer_type == Group
      [user, proposer.members.map(&:user)].uniq
    else
      [user, proposer].uniq
    end
  end

  def event_image?
    image?
  end

  def event_image
    image
  end

  def notify_if_enough
    # if status == 'active'
    # logger.warn('entered with ' + pledged.inspect + ' and pn: ' + points_needed.inspect)
    return unless pledges.sum(&:pledge) >= points_needed.to_i && status == 'active'

    return unless notified != true
    begin
      if proposer_type == 'Group'
        proposer.members.each do |user|
          IdeaMailer.proposal_for_review(user.user.email, self).deliver_now unless user.opt_out_everything == true || user.opt_in_ready != true
        end
      else
        IdeaMailer.proposal_for_review(proposer.email, self).deliver_now unless proposer.opt_out_everything == true || proposer.opt_in_ready != true
      end
      update_attribute(:notified, true)
    rescue StandardError
      notified = false
    end
  end

  private

  def update_image_attributes
    return unless image.present? && image?
    return unless image_changed?
    return unless image.file.exists?
    self.image_content_type = image.file.content_type
    self.image_size = image.file.size
    self.image_width, self.image_height = begin
      %x(identify -format "%wx%h" #{image.file.path}).split(/x/)
    rescue StandardError
      nil
    end
  end
end
