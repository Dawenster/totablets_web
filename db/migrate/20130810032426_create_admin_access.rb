class CreateAdminAccess < ActiveRecord::Migration
  def change
  	create_table :admin_access do |t|
      t.string :device_name_during_access
      t.string :location_during_access
      t.string :action

      t.timestamps
    end
  end
end
