class Post < ApplicationRecord
  belongs_to :user
  translates :title, :body, :fallbacks_for_empty_translations => true
  extend FriendlyId
  friendly_id :title_en , :use => [:slugged, :finders]
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['title'].blank? || x['body'].blank? }
  before_save :update_image_attributes
  belongs_to :era
  before_save :check_published
  mount_uploader :image, ImageUploader
  has_many :activities, as: :item, dependent: :destroy
  scope :published, -> () { where(published: true) }
  scope :sticky, -> () { where(sticky: true) }
  scope :not_sticky, -> () { where("sticky is not true") }
  scope :by_era, ->(era_id) { where(era_id: era_id)}
  validates_presence_of :era_id

  belongs_to :postcategory, optional: true
  belongs_to :meeting, optional: true

  has_many :comments, as: :item
  has_many :notifications, as: :item

  def as_mentionable
    {
      created_at: self.created_at,
      id: self.id,
      slug: self.slug,
      route: 'posts',
      image_url: '',
      name:  self.title,
      updated_at: self.updated_at
    }
  end

  def all_comments
    comments + comments.map(&:all_comments)
  end

  def total_comment_count
    all_comments.flatten.uniq.size
  end

  def name
    title
  end

  def root_comment
    self
  end
  def discussion
    comments
  end

  def title_en
    self.title(:en)
  end

  def category_text
    'news'
  end
  def check_published
    if self.published == true
      self.published_at ||= Time.now
    end
  end

  def feed_date
    published_at
  end

  def update_image_attributes
    if image.present? && image_changed?
      if image.file.exists?
        self.image_content_type = image.file.content_type
        self.image_size = image.file.size
        self.image_width, self.image_height = `identify -format "%wx%h" #{image.file.path}`.split(/x/)
      end
    end
  end

  private

  def should_generate_new_friendly_id?
    changed?
  end

end
