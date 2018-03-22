class AddSendAtToEmails < ActiveRecord::Migration[5.1]
  def change
    add_column :emails, :send_at, :datetime
  end
end
