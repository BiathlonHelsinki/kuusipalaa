class Meeting < ApplicationRecord
  belongs_to :place
  belongs_to :era
  translates :name, :description, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, reject_if: proc {|x| x['name'].blank? || x['description'].blank? }
  before_save :update_image_attributes
  mount_uploader :image, ImageUploader
  before_save :update_image_attributes
  extend FriendlyId
  friendly_id :title_en , :use => [:slugged, :finders]
  validates_presence_of :era_id, :start_at, :end_at
  scope :published, ->() {where(published: true)}
  scope :upcoming, -> () {where(["published is true and cancelled is not true and end_at >=  ?", Time.now.utc.strftime('%Y/%m/%d %H:%M')]) }
  has_many :posts
  has_many :rsvps

  has_many :comments, as: :item
  has_many :notifications, as: :item

  def title_en
    self.name(:en)
  end

  def all_comments
    comments + comments.map(&:all_comments)
  end

  def total_comment_count
    all_comments.flatten.uniq.size
  end

  def title
    name
  end

  def root_comment
    self
  end

  def discussion
    comments
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

  def in_future?
    start_at >= Time.current
  end

  private

  def should_generate_new_friendly_id?
    changed?
  end

end
