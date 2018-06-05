class AddSawidinfoToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :saw_idcard_info, :boolean, default: false
    User.all.each do |user|
      unless user.nfcs.empty?
        user.update_column(:saw_idcard_info, true)
      end
    end
  end
end
