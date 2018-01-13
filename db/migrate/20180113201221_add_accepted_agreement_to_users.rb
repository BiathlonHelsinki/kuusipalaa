class AddAcceptedAgreementToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :accepted_agreement, :boolean, null: false, default: false
  end
end
