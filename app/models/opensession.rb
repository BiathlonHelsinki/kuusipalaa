class Opensession < ApplicationRecord
  belongs_to :node
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper
  
  scope :by_node, ->(x) { where(node_id: x)}
  
  scope :between, -> (start_time, end_time) { 
    where( [ "closed_at is not null and (opened_at >= ?  AND  closed_at <= ?) OR ( opened_at >= ? AND closed_at <= ? ) OR (opened_at >= ? AND opened_at <= ?)  OR (opened_at < ? AND closed_at > ? )",
    start_time, end_time, start_time, end_time, start_time, end_time, start_time, end_time])
  }
  
  def checked_in
    if closed_at.nil?
      # parent_instance.instances_users.where(["created_at >= ?", opened_at])
      InstancesUser.includes(:user).where(["created_at >= ?", opened_at])
    else
      # parent_instance.instances_users.between(opened_at, closed_at)
      InstancesUser.includes(:user).between(opened_at, closed_at)
    end
  end
  
  def tagline
    if checked_in.empty?
      out = 'no check-ins'
    else
      out = pluralize(checked_in.size, 'check-in')
    end
    
    unless guest_tickets.empty? 
      out += ' & ' + pluralize(guest_tickets.size, 'guest ticket')
    end
    out
  end
  
  def guest_tickets
    if closed_at.nil?
      parent_instance.onetimers.unclaimed.where(["created_at >= ?", opened_at])
    else
      parent_instance.onetimers.unclaimed.between(opened_at, closed_at)
    end
  end
  
  def parent_instance
    i = Event.friendly.find('open-time').instances.where(["start_at <= ? AND end_at >= ?", opened_at, closed_at]).first
    if i.nil?
      i = Event.friendly.find('open-time').instances.where(["start_at <= ? ", opened_at ]).first
    end
    return i
  end
  
  def seconds_open
    end_time =  closed_at.nil? ? Time.current.utc : closed_at
    # elapsed_seconds = ((end_time - opened_at) * 24 * 60 * 60).to_i
    end_time - opened_at
  end
  
  def minutes_open

    (seconds_open / 60).to_i
  end
  
  
  
  def as_json(options = {})
    {
      :id => self.id,
      :title => 'Open ' + distance_of_time_in_words(seconds_open),
      :description => tagline , #parent_instance.instances_users.between(opened_at, closed_at).count.to_s + ' check-ins' + ' and ' + guest_tickets.size.to_s + ' guest tickets',
      :start => opened_at.strftime('%Y-%m-%d %H:%M:00'),
      :end => closed_at.nil? ? Time.current.strftime('%Y-%m-%d %H:%M:00') : (closed_at.strftime('%Y-%m-%d %H:%M:00')),
      :allDay => false, 
      :recurring => false,
      :url => '/opensessions/' + self.id.to_s
    }
    
  end
  
end
