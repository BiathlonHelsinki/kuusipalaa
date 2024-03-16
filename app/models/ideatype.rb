class Ideatype < ApplicationRecord
  extend FriendlyId
  friendly_id :name_en, use: %i[slugged finders history]
  translates :name, :description
  accepts_nested_attributes_for :translations, reject_if: proc { |x| x['name'].blank? && x['description'].blank? }
  validate :name_present_in_at_least_one_locale
  has_many :ideas

  delegate :name_en, to: self

  def name_present_in_at_least_one_locale
    return unless I18n.available_locales.map { |locale| translation_for(locale).name }.compact.empty?
    errors.add(:base, "You must specify a name in at least one available language.")
  end

  private

  def should_generate_new_friendly_id?
    changed?
  end
end
