class Authentication < ApplicationRecord
  belongs_to :user
  validates_presence_of :provider
  
  def self.find_for_oauth(auth)
     find_or_create_by(username: auth.username, provider: auth.provider)
  end
   
end
