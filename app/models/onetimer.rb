class Onetimer < ApplicationRecord
  # belongs_to :event, foreign_key: "event_id"
  belongs_to :instance
  belongs_to :user
  before_validation :generate_code
  validates_presence_of :code, :event_id

  scope :claimed, ->() { where(claimed: true) }
  scope :unclaimed, ->() { where(claimed: false) }
  scope :between, -> (start_time, end_time) { 
    where( [ "(created_at >= ?  AND  created_at <= ?) ",
    start_time, end_time ])
  }
  
  def generate_code
    if code.blank?
      self.code = (0...6).map { (65 + rand(26)).chr }.join + rand(9).to_s 
    end
  end
  
end
