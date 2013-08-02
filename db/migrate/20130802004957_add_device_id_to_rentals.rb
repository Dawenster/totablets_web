class AddDeviceIdToRentals < ActiveRecord::Migration
  def change
  	add_column :rentals, :device_id, :integer
  end
end
