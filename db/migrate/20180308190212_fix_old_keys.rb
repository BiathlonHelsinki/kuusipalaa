class FixOldKeys < ActiveRecord::Migration[5.1]
  def change
    User.all.each do |user|
      next if user.nfcs.empty?
      keys = user.nfcs
      next if keys.size < 2
      keys = keys.sort_by{|x| x.last_used.to_i }
      keys.each{|x| x.update_column(:keyholder, false) }
      if user.is_stakeholder?
        keys.last.update_column(:keyholder, true)
      end
    end
    add_index :nfcs, [:user_id, :keyholder], unique: true, name: "index_one_key", where: "(keyholder IS TRUE)"
  end
end
