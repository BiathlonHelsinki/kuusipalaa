class CreateEras < ActiveRecord::Migration[5.1]
  def change
    create_table :eras do |t|
      t.string :name
      t.boolean :active, default: false

      t.timestamps
    end
    Era.create(name: 'Temporary', active: false)
    Era.create(name: 'Experiment #2 transition', active: true)
    add_column :posts, :era_id, :integer
    Post.all.each do |p|
      p.update_attribute(:era_id, 1)
    end
  end
end
