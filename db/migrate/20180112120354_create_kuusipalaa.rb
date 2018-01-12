class CreateKuusipalaa < ActiveRecord::Migration[5.1]
  def self.up
    Era.create(name: 'Kuusi Palaa', active: true)
    e2 = Era.find(2)
    e2.update_attribute(:active, false)
  end

  def self.down

  end
end
