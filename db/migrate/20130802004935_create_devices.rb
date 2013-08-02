class CreateDevices < ActiveRecord::Migration
  def change
  	create_table :devices do |t|
      t.string :name
      t.string :profile_value
      t.string :device_type

      t.timestamps
    end
  end
end
