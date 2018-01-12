class AddMeetingIdToRsvps < ActiveRecord::Migration[5.1]
  def change
    add_column :rsvps, :meeting_id, :integer, index: true
  end
end
