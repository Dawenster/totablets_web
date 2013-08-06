class AddStripePreAuthIdToRentals < ActiveRecord::Migration
  def change
  	add_column :rentals, :stripe_pre_auth_id, :string
  end
end
