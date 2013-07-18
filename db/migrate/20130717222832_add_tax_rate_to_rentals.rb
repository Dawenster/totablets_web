class AddTaxRateToRentals < ActiveRecord::Migration
  def change
  	add_column :rentals, :tax_rate, :integer
  end
end
