class AddWarningToKeyInputs < ActiveRecord::Migration
  def change
  	add_column :key_inputs, :warning, :string
  end
end
