class AddContributorToActivities < ActiveRecord::Migration[5.1]
  def change
    add_reference :activities, :contributor, polymorphic: true
  end
end
