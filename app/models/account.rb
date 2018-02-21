class Account < ApplicationRecord
  # belongs_to :user
  validate :only_one_primary
  belongs_to :holder, polymorphic: true  
  scope :primary, -> () {  where(primary_account: true) }


  def only_one_primary
    if primary_account == true
      matches = Account.where(holder: holder).primary
    
      if persisted?
        matches = matches.where('id != ?', id)
      end
      if matches.exists?
        errors.add(:primary_account, 'cannot have another primary account')
      end
    else
      matches = Account.where(holder: holder).primary

      self.primary_account = matches.empty?
    end
  end
  
end


