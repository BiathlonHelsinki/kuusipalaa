class Post < ApplicationRecord
  belongs_to :user
  translates :title, :body
  extend FriendlyId
  friendly_id :title_en, use: %i[slugged finders]
  accepts_nested_attributes_for :translations, reject_if: proc { |x| x['title'].blank? || x['body'].blank? }
  before_save :update_image_attributes
  belongs_to :era
  before_save :check_published
  mount_uploader :image, ImageUploader
  has_many :activities, as: :item, dependent: :destroy
  scope :published, -> { where(published: true) }
  scope :sticky, -> { where(sticky: true) }
  scope :stakeholders, -> { where(only_stakeholders: true) }
  scope :not_stakeholders, -> { where(only_stakeholders: false) }
  scope :not_sticky, -> { where("sticky is not true") }
  scope :front, -> { where("hide_from_front is not true") }
  after_create :update_activity_feed
  scope :by_era, ->(era_id) { where(era_id:) }
  validates_presence_of :era_id

  belongs_to :postcategory, optional: true
  belongs_to :meeting, optional: true

  has_many :comments, as: :item
  has_many :notifications, as: :item

  def as_mentionable
    {
      created_at: created_at,
      id: id,
      slug: slug,
      route: 'posts',
      image_url: '',
      name: title,
      updated_at: updated_at
    }
  end

  def all_comments
    comments + comments.map(&:all_comments)
  end

  def total_comment_count
    all_comments.flatten.uniq.size
  end

  def item
    self
  end

  def name
    title
  end

  def event_image?
    image?
  end

  def root_comment
    self
  end

  def discussion
    comments
  end

  def description
    body
  end

  def title_en
    title_en
  end

  def category_text
    'news'
  end

  def check_published
    return unless published == true
    self.published_at ||= Time.now
  end

  def feed_date
    published_at
  end

  def update_activity_feed
    Activity.create(user: user, contributor: user, item: self, description: "posted", addition: 0)
  end

  def update_image_attributes
    return unless image.present? && image_changed?
    return unless image.file.exists?
    self.image_content_type = image.file.content_type
    self.image_size = image.file.size
    self.image_width, self.image_height = %x(identify -format "%wx%h" #{image.file.path}).split(/x/)
  end

  private

  def should_generate_new_friendly_id?
    changed?
  end
end
