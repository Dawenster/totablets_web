class RemoveDeviceNameFromRentals < ActiveRecord::Migration
  def change
  	remove_column :rentals, :device_name
  end
end
