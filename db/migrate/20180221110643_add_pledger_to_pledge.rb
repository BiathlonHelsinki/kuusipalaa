class AddPledgerToPledge < ActiveRecord::Migration[5.1]
  def self.up
    add_reference :pledges, :pledger, polymorphic: true
    Pledge.all.each do |p|
      next if p.user.nil?
      p.update_column(:pledger_type, 'User')
      p.update_column(:pledger_id, p.user_id)

    end
  end
end
