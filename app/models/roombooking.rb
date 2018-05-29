class Roombooking < ApplicationRecord
  # include PgSearch
  # multisearchable :against => [:purpose]
  belongs_to :user
  belongs_to :booker, polymorphic: true
  # belongs_to :ethtransaction
  # belongs_to :rate
  has_many :activities, as: :item, dependent: :destroy
    
  validates_presence_of :user_id, :points_needed
  
  scope :between, -> (start_time, end_time) { 
    where( [ "(day >= ?  AND  day <= ?)",  start_time, end_time ])
  }
  

  def as_json(options = {})
    {
      :id => self.id,
      :title => self.booker.nil? ? 'Kuusi Palaa is closed' : self.booker.display_name + "\n" + (self.purpose || '') + (self.purpose.blank? ? '' : "\n") + start_at.localtime.strftime("%H:%M") + ' - ' + end_at.localtime.strftime("%H:%M"),
      :description => self.purpose || "",
      icon_url: self.user.nil? ? '' : self.user.avatar.url(:thumb).gsub(/development/, 'production'),
      :start => start_at.localtime, #.strftime('%Y-%m-%d 00:00:01'),
      :end =>  end_at.localtime, #.strftime('%Y-%m-%d 23:59:59'),
      :allDay => true, 
      :recurring => false,
      :temps => self.points_needed,
      class: 'booking',
      :url => self.user.nil? ? '/posts/courtyard-closed-thursday-31-may' : Rails.application.routes.url_helpers.user_path(self.user)
    }
    
  end

  def open_time
    false
  end

  def name
    I18n.t(:private_event_in_back_room, user: booker.display_name)
  end

  def start_at_date
    start_at.nil? ? nil : start_at.strftime('%Y-%m-%d')
  end

  def end_at_date
    end_at.nil? ? nil : end_at.strftime('%Y-%m-%d')
  end
  
  
end
