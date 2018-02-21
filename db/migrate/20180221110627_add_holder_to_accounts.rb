class AddHolderToAccounts < ActiveRecord::Migration[5.1]
  def self.up
    add_reference :accounts, :holder, polymorphic: true
  end




end
