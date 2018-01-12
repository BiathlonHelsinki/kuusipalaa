class CreateStakes < ActiveRecord::Migration[5.1]
  def change
    create_table :stakes do |t|
      t.references :owner, polymorphic: true
      t.boolean :paid, null: false, default: false
      t.references :season, foreign_key: true
      t.string :notes
      t.datetime :paid_at
      t.string :invoice
      t.string :invoice_content_type
      t.integer :invoice_size, length: 8
      t.integer :amount, null: false, default: 1
      t.text :comments

      t.timestamps
    end
  end
end
