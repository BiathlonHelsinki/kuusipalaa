class FixSequences < ActiveRecord::Migration[5.1]
  def change
    execute('UPDATE instances SET sequence = 1 where place_id = 2')
  end
end
