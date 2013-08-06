class RemoveStripePreAuthIdFromRentalsAndAddPreAuthId < ActiveRecord::Migration
  def change
  	remove_column :rentals, :stripe_pre_auth_id
  end
end
