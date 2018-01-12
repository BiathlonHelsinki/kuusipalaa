class Page < ApplicationRecord
  audited except: :image
  resourcify
  extend FriendlyId
  friendly_id :title_en , :use => [ :slugged, :finders, :history]
  mount_uploader :image, ImageUploader
  # process_in_background :image

  translates :title, :body
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['title'].blank? && x['body'].blank? }
  before_save :update_image_attributes
  validate :title_present_in_at_least_one_locale
  scope :published, -> () { where(published: true) }


  def title_en
    self.title(:en)
  end

  def title_present_in_at_least_one_locale
    if I18n.available_locales.map { |locale| translation_for(locale).title }.compact.empty?
      errors.add(:base, "You must specify a title in at least one available language.")
    end
  end

  private

  def should_generate_new_friendly_id?
    changed?
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

end
