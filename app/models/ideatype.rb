class Ideatype < ApplicationRecord
  extend FriendlyId 
  friendly_id :name_en , :use => [ :slugged, :finders, :history]
  translates :name, :description
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['name'].blank? && x['description'].blank? }
  validate :name_present_in_at_least_one_locale
  has_many :ideas

  def name_en
    self.name(:en)
  end

  def name_present_in_at_least_one_locale
    if I18n.available_locales.map { |locale| translation_for(locale).name }.compact.empty?
      errors.add(:base, "You must specify a name in at least one available language.")
    end
  end

  private

  def should_generate_new_friendly_id?
    changed?
  end

end
