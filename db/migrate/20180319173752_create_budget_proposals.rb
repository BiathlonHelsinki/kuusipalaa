class CreateBudgetProposals < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_proposals do |t|
      t.references :season, foreign_key: true
      t.references :proposer, polymorphic: true
      t.references :user
      t.string :name
      t.string :description
      t.float :amount
      t.string :link
      t.boolean :status

      t.timestamps
    end
  end
end
