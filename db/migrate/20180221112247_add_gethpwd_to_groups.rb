class AddGethpwdToGroups < ActiveRecord::Migration[5.1]
  def self.up
    Group.all.each do |g|
      g.update_column(:geth_pwd, SecureRandom.hex(13))
    end
  end

end
