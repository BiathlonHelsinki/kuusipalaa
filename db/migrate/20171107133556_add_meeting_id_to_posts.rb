class AddMeetingIdToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :meeting_id, :integer, index: true

  end
end
