class Page < ApplicationRecord
  audited except: :image
  resourcify
  extend FriendlyId
  friendly_id :title_en, use: %i[slugged finders history]
  mount_uploader :image, ImageUploader
  mount_uploader :pdf, AttachmentUploader
  # process_in_background :image

  translates :title, :body
  accepts_nested_attributes_for :translations, reject_if: proc { |x| x['title'].blank? && x['body'].blank? }
  before_save :update_image_attributes
  validate :title_present_in_at_least_one_locale
  scope :stakeholders, -> { where(only_stakeholders: true) }
  scope :published, -> { where(published: true) }
  has_many :questions

  delegate :title_en, to: self

  def name
    title
  end

  def notifications
    []
  end

  def title_present_in_at_least_one_locale
    return unless I18n.available_locales.map { |locale| translation_for(locale).title }.compact.empty?
    errors.add(:base, "You must specify a title in at least one available language.")
  end

  private

  def should_generate_new_friendly_id?
    changed?
  end

  def update_image_attributes
    return unless image.present? && image_changed?
    return unless image.file.exists?
    self.image_content_type = image.file.content_type
    self.image_size = image.file.size
    self.image_width, self.image_height = %x(identify -format "%wx%h" #{image.file.path}).split(/x/)
  end

  def update_pdf_attributes
    return unless pdf.present? && pdf_changed?
    return unless pdf.file.exists?
    self.pdf_content_type = pdf.file.content_type
    self.pdf_size = pdf.file.size
  end
end
