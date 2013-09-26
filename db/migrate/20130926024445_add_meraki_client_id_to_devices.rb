class AddMerakiClientIdToDevices < ActiveRecord::Migration
  def change
  	add_column :devices, :meraki_client_id, :string
  end
end
