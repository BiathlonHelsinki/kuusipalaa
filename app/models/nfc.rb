class Nfc < ApplicationRecord
  belongs_to :user
  
  def self.keyholder?
    keyholder
  end
  
end
