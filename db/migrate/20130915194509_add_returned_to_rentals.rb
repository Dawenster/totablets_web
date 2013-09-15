class AddReturnedToRentals < ActiveRecord::Migration
  def change
  	add_column :rentals, :returned, :boolean, :default => false
  end
end
