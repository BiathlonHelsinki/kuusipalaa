class AddDueToStakes < ActiveRecord::Migration[5.1]
  def change
    add_column :stakes, :invoice_due, :date
    add_column :stakes, :paidconfirmation, :string
    add_column :stakes, :paidconfirmation_content_type, :string
    add_column :stakes, :paidconfirmation_size, :integer, length: 8
    add_column :stakes, :includes_share, :boolean
    add_column :stakes, :includes_membership_fee, :boolean
  end
end
