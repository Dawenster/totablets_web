class AddLocationIdToDevices < ActiveRecord::Migration
  def change
  	add_column :devices, :location_id, :integer
  end
end
