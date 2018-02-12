class Season < ApplicationRecord
  has_many :stakes

  def complete?
    stakes.sum(&:invoice_amount) >= amount_needed
  end
  
end
