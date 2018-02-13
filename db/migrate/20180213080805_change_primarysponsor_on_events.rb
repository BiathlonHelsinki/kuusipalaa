class ChangePrimarysponsorOnEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :primary_sponsor_type, :string
    add_index :events, [:primary_sponsor_id, :primary_sponsor_type]
    execute("UPDATE events SET primary_sponsor_type='User'")

  end
end
