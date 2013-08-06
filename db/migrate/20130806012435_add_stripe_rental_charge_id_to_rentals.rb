class AddStripeRentalChargeIdToRentals < ActiveRecord::Migration
  def change
  	add_column :rentals, :stripe_rental_charge_id, :string
  end
end
