class CreatePreAuth < ActiveRecord::Migration
  def change
  	create_table :pre_auths do |t|
  		t.string :stripe_pre_auth_id
  		t.integer :pre_auth_amount
  		t.integer :captured_amount, :default => 0
  		t.text :description
      t.references :rental

      t.timestamps
    end
  end
end
