class AddIdeaItToEvents < ActiveRecord::Migration[5.1]
  def change
    add_reference :events, :idea, foreign_key: true
  end
end
