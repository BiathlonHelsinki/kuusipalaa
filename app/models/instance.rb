class Instance < ApplicationRecord
  belongs_to :event
  belongs_to :place
  translates :name, :description
  accepts_nested_attributes_for :translations, reject_if: proc { |x| x['name'].blank? && x['description'].blank? }
  accepts_nested_attributes_for :event
  has_many :instances_users
  has_many :instances_organisers
  has_many :users, through: :instances_users
  has_many :organisers, through: :instances_organisers
  has_many :onetimers, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :rsvps
  has_many :activities, as: :item
  scope :on_day, ->(day) {
    where(["(start_at >= ?  AND  start_at <= ?) OR ( end_at > ? AND end_at <= ? )   OR (start_at < ? AND end_at > ? )",
           day.to_date.at_midnight.to_fs(:db), day.to_date.end_of_day.to_fs(:db),
           day.to_date.at_midnight.to_fs(:db), day.to_date.end_of_day.to_fs(:db),
           day.to_date.at_midnight.to_fs(:db), day.to_date.end_of_day.to_fs(:db)])
  }

  scope :kuusi_palaa, -> { where("start_at >= '2018-03-01'") }
  scope :between, ->(start_time, end_time) {
    where(["(start_at >= ?  AND  end_at <= ?) OR ( start_at >= ? AND end_at <= ? ) OR (start_at >= ? AND start_at <= ?)  OR (start_at < ? AND end_at > ? )",
           start_time.to_date.at_midnight.to_fs(:db), end_time.to_date.end_of_day.to_fs(:db),
           start_time.to_date.at_midnight.to_fs(:db), end_time.to_date.end_of_day.to_fs(:db),
           start_time.to_date.at_midnight.to_fs(:db), end_time.to_date.end_of_day.to_fs(:db),
           start_time.to_date.at_midnight.to_fs(:db), end_time.to_date.end_of_day.to_fs(:db)])
  }
  scope :published, -> { where(published: true) }
  scope :calendered, -> { where("open_time is not true") }
  scope :not_cancelled, -> { where('cancelled is not true') }
  scope :back_room, -> { where("room_needed in (2,3)") }
  scope :meetings, -> { where(is_meeting: true) }
  scope :future, -> { where(["published is true and cancelled is not true and end_at >=  ?", Time.now.utc.strftime('%Y/%m/%d %H:%M')]) }
  scope :past, -> { where(["end_at <  ?", Time.now.utc.strftime('%Y/%m/%d %H:%M')]) }
  scope :current, -> { where(["start_at <=  ? and end_at >= ?", Time.current.utc.strftime('%Y/%m/%d %H:%M'), Time.current.utc.strftime('%Y/%m/%d %H:%M')]) }
  has_many :userphotos
  has_many :userthoughts
  has_many :userlinks
  extend FriendlyId
  friendly_id :name_en, use: %i[slugged finders history]

  def scheduler
    activities.where(description: 'published_event').empty? ? event.primary_sponsor : activities.find_by(description: 'published_event').contributor
  end

  def as_json(_options = {})
    {
      id: id,
      title: name,
      description: description || "",
      calendar_start: calendar_start_at.localtime.strftime('%Y-%m-%d %H:%M:00'),
      start: start_at.localtime.strftime('%Y-%m-%d %H:%M:00'),
      end: end_at.localtime.strftime('%Y-%m-%d %H:%M:00'),
      allDay: false,
      recurring: false,
      temps: cost_bb,
      cancelled: cancelled,
      class: slug == 'closed' ? 'closed' : 'event',
      url: slug == 'closed' ? '/seasons/2/stakes/new' : Rails.application.routes.url_helpers.event_instance_path(event.slug, slug)
    }
  end

  def calendar_start_at
    start_at - 1.hour
  end

  def other_instances
    event.instances.where.not(id:)
  end

  def item
    self
  end

  delegate :comments, to: :event

  def get_sequence_name
    get_sequence.map(&:name).uniq.size > 1 ? event.name : name
  end

  def sequence_size
    get_sequence.size
  end

  def get_sequence
    event.instances.where(sequence:).order(:start_at)
  end

  def event_image
    image? ? image : event.image
  end

  def event_image?
    image? ? true : event.image?
  end

  # def read_translated_attribute(name, options)
  #   # logger.warn('name is ' + name.inspect)
  #   # logger.warn('locale is ' + Globalize.locale.inspect)
  #   globalize.stash.contains?(Globalize.locale, name) ? globalize.stash.read(Globalize.locale, name) : translation_for(Globalize.locale).send(name)
  # end

  def responsible_people
    [event.primary_sponsor_type == 'Group' ? event.primary_sponsor.privileged : event.primary_sponsor, organisers].flatten.compact.uniq
  end

  def viewpoints
    [userphotos, userlinks, userthoughts].flatten.compact
  end

  delegate :discussion, to: :event

  delegate :idea, to: :event

  def proposal
    idea
  end

  def in_future?
    start_at.localtime >= Time.current
  end

  def already_happened?
    get_sequence.last.end_at.localtime <= Time.current.localtime
  end
end
