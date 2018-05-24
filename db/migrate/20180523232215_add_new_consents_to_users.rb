class AddNewConsentsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :accepted_tos, :boolean
    add_column :users, :opt_in_weekly_newsletter, :boolean
    add_column :users, :opt_in_mentions, :boolean
    add_column :users, :opt_in_points, :boolean
    add_column :users, :opt_in_ready, :boolean
    add_column :users, :opt_out_everything, :boolean, null: false, default: false
  end
end
