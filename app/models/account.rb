class Account < ApplicationRecord
  belongs_to :user
  validate :only_one_primary
  
  scope :primary, -> () {  where(primary_account: true) }


  def only_one_primary
    if primary_account == true
      matches = Account.where(user_id: user_id).primary
    
      if persisted?
        matches = matches.where('id != ?', id)
      end
      if matches.exists?
        errors.add(:primary_account, 'cannot have another primary account')
      end
    else
      matches = Account.where(user_id: user_id).primary

      self.primary_account = matches.empty?
    end
  end
  
end


