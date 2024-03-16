class Additionaltime < ApplicationRecord
  belongs_to :item, polymorphic: true
  scope :between, ->(start_time, end_time) {
    where(["(start_at >= ?  AND  end_at <= ?) OR ( start_at >= ? AND end_at <= ? ) OR (start_at >= ? AND start_at <= ?)  OR (start_at < ? AND end_at > ? )",
           start_time.to_date.at_midnight.to_s, end_time.to_date.end_of_day.to_fs(:db), start_time.to_date.at_midnight.to_s, end_time.to_date.end_of_day.to_fs(:db),
           start_time.to_date.at_midnight.to_s, end_time.to_date.end_of_day.to_fs(:db), start_time.to_date.at_midnight.to_s, end_time.to_date.end_of_day.to_fs(:db)])
  }
  def as_json(_options = {})
    {
      id: id,
      title: item.name,
      description: item.short_description || "",
      start: calendar_start_at.nil? ? nil : calendar_start_at.localtime.strftime('%Y-%m-%d %H:%M:00'),
      end: end_at.nil? ? nil : end_at.localtime.strftime('%Y-%m-%d %H:%M:00'),
      allDay: false,
      recurring: false,
      temps: item.points_needed,
      class: 'proposal',
      url: Rails.application.routes.url_helpers.idea_path(item.slug)
    }
  end

  def calendar_start_at
    start_at - 1.hour
  end

  def start_at_date
    start_at.nil? ? nil : start_at.strftime('%Y-%m-%d')
  end

  def end_at_date
    end_at.nil? ? nil : end_at.strftime('%Y-%m-%d')
  end
end
