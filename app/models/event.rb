class Event < ApplicationRecord
  resourcify
  belongs_to :idea, optional: true
  belongs_to :place
  belongs_to :proposal, optional: true
  belongs_to :primary_sponsor, polymorphic: true  
  has_many :instances, foreign_key: 'event_id', dependent: :destroy
  translates :name, :description, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, :reject_if => proc { |x| x['name'].blank? && x['description'].blank? }
  accepts_nested_attributes_for :instances, :reject_if => proc { |x| x['start_at'].blank? || x['end_at'].blank? }
  has_many :notifications, as: :item
  has_many :ideas, as: :parent
  belongs_to :parent, class_name: 'Event', optional: true
  has_one :child, class_name: 'Event', foreign_key: :parent_id
  extend FriendlyId
  friendly_id :name_en, use: [:slugged, :finders] # :history]
  mount_uploader :image, ImageUploader
  process_in_background :image

  validates_presence_of :place_id, :start_at, :primary_sponsor_id
  validate :name_present_in_at_least_one_locale
  before_save :update_image_attributes
  has_many :comments, as: :item, :dependent => :destroy
  has_many :pledges, -> { where item_type: 'Event' },
                          foreign_key: :item_id,
                          foreign_type: :item_type, dependent: :destroy
  acts_as_nested_set

  # validate :at_least_one_instance

  scope :published, -> () { where(published: true) }
  scope :has_events_on, -> (*args) { where(['published is true and (date(start_at) = ? OR (end_at is not null AND (date(start_at) <= ? AND date(end_at) >= ?)))', args.first, args.first, args.first] )}
  scope :between, -> (start_time, end_time) { 
    where( [ "(start_at >= ?  AND  end_at <= ?) OR ( start_at >= ? AND end_at <= ? ) OR (start_at >= ? AND start_at <= ?)  OR (start_at < ? AND end_at > ? )",
    start_time, end_time, start_time, end_time, start_time, end_time, start_time, end_time])
  }

  def as_mentionable
    {
      created_at: self.created_at,
      id: self.id,
      slug: self.slug,
      image_url: self.image.url(:thumb).gsub(/development/, 'production'),
      name:  self.name,
      route: 'events',
      updated_at: self.updated_at
    }
  end
  
  def discussion
    comments
  end

  def instances_copied
    new_instances = []
    instances.each{|x| 
      n = x.dup
      n.created_at = n.start_at
      new_instances.push(n)
    }
    return new_instances
  end

  def discussion_and_timeline
    [proposal, idea, instances.map(&:rsvps), ideas, ideas.empty? ? nil : ideas.map(&:pledges), idea.nil? ? proposal.pledges : idea.pledges, comments, instances, instances_copied, instances.map(&:viewpoints)].flatten.compact.sort_by(&:created_at)
  end

  def dormant?
    if created_at >= 3.months.ago 
      return false
    else
      if (pledges.empty? || pledges.last.created_at < 3.months.ago) && (comments.empty? || comments.last.created_at < 3.months.ago) && ( instances.published.empty? || instances.published.last.start_at < 3.months.ago )
        return true
      end
    end
  end

  def needed_for_next
    #  TODO fix this
    100
  end

  def sequences
    instances.group_by(&:sequence)
  end

  def next_sequence
    instances.map(&:sequence).map(&:to_i).sort.last + 1
  end
  
  def discussion
    comments  
  end

  def root_comment
    self
  end

  def future?
    self.start_at >= Date.parse(Time.now.strftime('%Y/%m/%d'))
  end
  
  # def read_translated_attribute(name, locale)
  #   globalize.stash.contains?(locale, name) ? globalize.stash.read(locale, name) : translation_for(locale).send(name) 
  # end

  def item
    self
  end
  
  def name_en
    self.name(:en)
  end
  
  def name_present_in_at_least_one_locale
    if I18n.available_locales.map { |locale| translation_for(locale).name }.compact.empty?
      errors.add(:base, "You must specify an event name in at least one available language.")
    end
  end  
  private

    def update_image_attributes
    if image.present? && image_changed?
      if image.file.exists?
        self.image_content_type = image.file.content_type
        self.image_size = image.file.size
        self.image_width, self.image_height = `identify -format "%wx%h" #{image.file.path}`.split(/x/)
      end
    end
  end

  
end