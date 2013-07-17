class Rental < ActiveRecord::Base
	attr_accessible :device_name, :location_detail, :days, :start_date, :end_date, :subtotal, :tax_amount, :grand_total, :currency,
									:customer, :location

	has_one :customer
	has_one :location
	has_many :taxes
end