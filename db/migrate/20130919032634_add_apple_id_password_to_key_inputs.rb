class AddAppleIdPasswordToKeyInputs < ActiveRecord::Migration
  def change
  	add_column :key_inputs, :apple_id_password, :string
  end
end
