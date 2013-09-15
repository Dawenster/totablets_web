class AddDemoToDevicesAndRentals < ActiveRecord::Migration
  def change
  	add_column :devices, :demo, :boolean, :default => true
  	add_column :rentals, :demo, :boolean, :default => true
  end
end
