class CreateRentals < ActiveRecord::Migration
  def change
  	create_table :rentals do |t|
      t.string :device_name
      t.string :location_detail
      t.integer :days
      t.datetime :start_date
      t.datetime :end_date
      t.integer :subtotal
      t.integer :tax_amount
      t.integer :grand_total
      t.string :currency
      t.references :customer
      t.references :location

      t.timestamps
    end
  end
end
