class Instance < ApplicationRecord
  belongs_to :event, foreign_key: 'event_id'
  belongs_to :place
  translates :name, :description, :fallbacks_for_empty_translations => false
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['name'].blank? && x['description'].blank? }
  accepts_nested_attributes_for :event
  has_many :instances_users
  has_many :instances_organisers
  has_many :users, through: :instances_users
  has_many :organisers, through: :instances_organisers
  has_many :onetimers, dependent: :destroy
  has_many :rsvps
  scope :between, -> (start_time, end_time) { 
    where( [ "(start_at >= ?  AND  end_at <= ?) OR ( start_at >= ? AND end_at <= ? ) OR (start_at >= ? AND start_at <= ?)  OR (start_at < ? AND end_at > ? )",
    start_time.to_date.at_midnight.to_s(:db), end_time.to_date.end_of_day.to_s(:db), start_time.to_date.at_midnight.to_s(:db), end_time.to_date.end_of_day.to_s(:db), 
    start_time.to_date.at_midnight.to_s(:db), end_time.to_date.end_of_day.to_s(:db), start_time.to_date.at_midnight.to_s(:db), end_time.to_date.end_of_day.to_s(:db)])
  }
  scope :published, -> () { where(published: true) }
  scope :not_cancelled, -> { where('cancelled is not true') }
  scope :meetings, -> () {where(is_meeting: true)}
  scope :future, -> () {where(["published is true and cancelled is not true and end_at >=  ?", Time.now.utc.strftime('%Y/%m/%d %H:%M')]) }
  scope :past, -> () {where(["end_at <  ?", Time.now.utc.strftime('%Y/%m/%d %H:%M')]) }
  scope :current, -> () { where(["start_at <=  ? and end_at >= ?", Time.current.utc.strftime('%Y/%m/%d %H:%M'), Time.current.utc.strftime('%Y/%m/%d %H:%M') ]) }
   extend FriendlyId
  friendly_id :name_en , :use => [ :slugged, :finders, :history]
  def as_json(options = {})
    {
      :id => self.id,
      :title =>  self.name,
      :description => self.description || "",
      :start => start_at.localtime.strftime('%Y-%m-%d %H:%M:00'),
      :end => end_at.localtime.strftime('%Y-%m-%d %H:%M:00'),
      :allDay => false, 
      :recurring => false,
      :temps => self.cost_bb,
      :cancelled => self.cancelled,
      :url => Rails.application.routes.url_helpers.event_instance_path(event.slug, slug)
    } 
  end 

  def responsible_people
    [event.primary_sponsor, organisers].flatten.compact.uniq
  end

  def idea
    event.idea
  end

  def proposal
    idea
  end
  
  def in_future?
    start_at.localtime >= Time.current
  end
  

end