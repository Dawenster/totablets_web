class Rental < ActiveRecord::Base
	attr_accessible :device_name, :location_detail, :days, :start_date, :end_date, :rate, :subtotal, :tax_rate, :tax_amount, :grand_total,
									:currency, :customer, :location

	belongs_to :customer
	belongs_to :location
	has_and_belongs_to_many :taxes, :class_name => 'Tax'
end