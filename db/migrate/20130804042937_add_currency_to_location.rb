class AddCurrencyToLocation < ActiveRecord::Migration
  def change
  	add_column :locations, :currency, :string
  end
end
