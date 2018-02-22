class AddAfterHolder < ActiveRecord::Migration[5.1]
  

  def self.up
    Account.all.each do |a|
      next if a.user_id.nil?
      a.update_column(:holder_type, 'User')
      a.update_column(:holder_id, a.user_id)
    end

  end
end
