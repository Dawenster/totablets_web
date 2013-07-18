class AddRateToRentals < ActiveRecord::Migration
  def change
  	add_column :rentals, :rate, :integer
  end
end
