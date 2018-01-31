class CreateIdeas < ActiveRecord::Migration[5.1]
  def change
    create_table :ideas do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :has_other_timeslots
      t.boolean :timeslot_undetermined
      t.references :proposer, polymorphic: true
      t.references :parent, polymorphic: true
      t.string :name
      t.text :short_description
      t.text :proposal_text
      t.integer :comment_count
      t.references :proposalstatus, foreign_key: true
      t.text :special_notes
      t.references :ideatype, foreign_key: true
      t.string :slug
      t.timestamps
    end
  end
end
