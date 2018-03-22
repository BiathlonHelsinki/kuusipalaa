class Season < ApplicationRecord
  has_many :stakes
  has_many :budgetproposals
  validates_presence_of :number, :start_at, :end_at

  def complete?
    stakes.sum(&:invoice_amount) >= amount_needed
  end


end
