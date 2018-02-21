class AddKeepGoingToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :keep_going, :boolean
  end
end
