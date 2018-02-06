class CreatePaymenttypes < ActiveRecord::Migration[5.1]
  def change
    create_table :paymenttypes do |t|
      t.string :name

      t.timestamps
    end
    add_column :stakes, :paymenttype_id, :integer, default: 1, null: false
    Paymenttype.create(name: 'bank_transfer')
    Paymenttype.create(name: 'credit_card')
  end
end
