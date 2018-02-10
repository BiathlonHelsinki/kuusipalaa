class CreateAdditionaltimes < ActiveRecord::Migration[5.1]
  def change
    create_table :additionaltimes do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.references :item, polymorphic: true

      t.timestamps
    end
  end
end
