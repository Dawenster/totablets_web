class AddAdminPasswordToDevices < ActiveRecord::Migration
  def change
  	add_column :devices, :admin_password, :string
  end
end
