class Place < ApplicationRecord
  translates :name, :fallbacks_for_empty_translations => true
  resourcify
  geocoded_by :address
  extend FriendlyId
  friendly_id :name_en, :use => [:finders, :history]
  after_validation :geocode, :on => :create
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['name'].blank? }
  
  def should_generate_new_friendly_id?
    name_changed?
  end
  
  def name_en
    self.name(:en)
  end

  def address
    [address1 , address2, city, country, postcode].delete_if {|x| x.blank? }.compact.join(', ')
  end
  
  def address_no_country
    [address1 , address2, city].delete_if {|x| x.blank? }.compact.join(', ')
  end
  
end
