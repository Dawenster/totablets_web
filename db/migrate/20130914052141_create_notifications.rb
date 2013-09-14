class CreateNotifications < ActiveRecord::Migration
  def change
  	create_table :notifications do |t|
  		t.string :message
  		t.integer :hours_before_rental_ends
  		t.integer :hour_on_last_day

      t.timestamps
    end
  end
end
