class CreateExpenses < ActiveRecord::Migration[5.1]
  def change
    create_table :expenses do |t|
      t.date :date_spent
      t.string :recipient
      t.string :description
      t.float :amount
      t.float :alv
      t.string :receipt
      t.string :receipt_content_type
      t.integer :receipt_size
      t.text :notes

      t.timestamps
    end
  end
end
