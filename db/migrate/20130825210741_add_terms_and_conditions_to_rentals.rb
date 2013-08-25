class AddTermsAndConditionsToRentals < ActiveRecord::Migration
  def change
  	add_column :rentals, :terms_and_conditions, :text
  end
end
