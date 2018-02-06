class AddStripeTokenToStakes < ActiveRecord::Migration[5.1]
  def change
    add_column :stakes, :stripe_token, :string
  end
end
