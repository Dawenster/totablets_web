class CreateLocationsTaxes < ActiveRecord::Migration
  def change
  	create_table :locations_taxes do |t|
      t.belongs_to :location
      t.belongs_to :tax
    end
  end
end
