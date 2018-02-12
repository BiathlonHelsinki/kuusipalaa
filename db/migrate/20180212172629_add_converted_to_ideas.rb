class AddConvertedToIdeas < ActiveRecord::Migration[5.1]
  def change
    # add_column :ideas, :converted, :boolean
    add_reference :ideas, :converted, polymorphic: true
  end
end
