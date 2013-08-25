class CreateKeyInput < ActiveRecord::Migration
  def change
    create_table :key_inputs do |t|
      t.integer :rate
      t.integer :pre_auth_amount
      t.text :terms_and_conditions

      t.timestamps
    end
  end
end
