class CreateSeasons < ActiveRecord::Migration[5.1]
  def change
    create_table :seasons do |t|
      t.integer :number
      t.date :start_at
      t.date :end_at
      t.integer :stake_count

      t.timestamps
    end
  end
end
