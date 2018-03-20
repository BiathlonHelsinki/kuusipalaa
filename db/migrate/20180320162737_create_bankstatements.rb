class CreateBankstatements < ActiveRecord::Migration[5.1]
  def change
    create_table :bankstatements do |t|
      t.integer :month
      t.integer :year
      t.string :pdf
      t.string :pdf_content_type
      t.integer :pdf_size, length: 8

      t.timestamps
    end
  end
end
