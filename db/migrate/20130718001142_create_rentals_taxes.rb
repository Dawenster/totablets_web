class CreateRentalsTaxes < ActiveRecord::Migration
  def change
  	create_table :rentals_taxes do |t|
      t.belongs_to :rental
      t.belongs_to :tax
    end
  end
end
