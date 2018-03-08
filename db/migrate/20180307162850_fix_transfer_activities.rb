class FixTransferActivities < ActiveRecord::Migration[5.1]
  def change
    Activity.where(description: 'received_from').each do |a|
      recipient = a.user
      sender = a.item
      a.update_column(:user_id, a.item_id)
      a.update_column(:item_id, recipient.id)
      a.update_column(:contributor_type, 'User')
      a.update_column(:contributor_id, sender.id)
    end
  end
end
