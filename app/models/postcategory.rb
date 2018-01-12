class Postcategory < ApplicationRecord
  translates :name, :fallbacks_for_empty_translations => true
  extend FriendlyId
  friendly_id :title_en , :use => [:slugged, :finders]
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['name'].blank? }
  has_many :posts
  
  def title_en
    self.name(:en)
  end
  
  private
  
  def should_generate_new_friendly_id?
    changed?
  end
  
end
