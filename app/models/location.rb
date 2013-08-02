class Location < ActiveRecord::Base
	attr_accessible :name, :location_type, :city, :province_or_state, :country

	has_many :rentals
	has_many :customers
	has_many :devices

	validates :name, :presence => true
	validates :location_type, :presence => true
	validates :city, :presence => true
	validates :province_or_state, :presence => true
	validates :country, :presence => true
end