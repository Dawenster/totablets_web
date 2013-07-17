class CreateTaxes < ActiveRecord::Migration
  def change
  	create_table :taxes do |t|
  		t.string :name
  		t.integer :rate

      t.timestamps
    end
  end
end
