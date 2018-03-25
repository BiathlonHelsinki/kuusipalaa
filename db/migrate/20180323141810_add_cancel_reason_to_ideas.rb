class AddCancelReasonToIdeas < ActiveRecord::Migration[5.1]
  def change
    add_column :ideas, :cancel_reason, :string
  end
end
