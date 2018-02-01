class AddContributorsToComments < ActiveRecord::Migration[5.1]
  def self.up
    add_reference :comments, :contributor, polymorphic: true
    Comment.all.each do |c|
      c.update_attribute(:contributor_type, 'User')
      c.update_attribute(:contributor_id, c.user_id)
    end
    
  end

  def self.down
    add_column :comments, :user_id, :integer
    remove_reference :comments, :contributor
  end
end
