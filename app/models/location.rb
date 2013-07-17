class Location < ActiveRecord::Base
	attr_accessible :name, :type, :city, :province_or_state, :country

	has_many :rentals
	has_many :customers
end