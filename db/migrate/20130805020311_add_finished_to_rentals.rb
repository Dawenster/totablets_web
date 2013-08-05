class AddFinishedToRentals < ActiveRecord::Migration
  def change
  	add_column :rentals, :finished, :boolean
  end
end
