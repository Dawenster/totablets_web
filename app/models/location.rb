class Location < ActiveRecord::Base
	attr_accessible :name, :location_type, :city, :province_or_state, :country, :tax, :tax_id, :tax_ids, :currency, :timezone

	has_many :rentals
	has_many :customers
	has_many :devices
	has_and_belongs_to_many :taxes

	validates :name, :presence => true
	validates :location_type, :presence => true
	validates :city, :presence => true
	validates :province_or_state, :presence => true
	validates :country, :presence => true
	validates :currency, :presence => true
	validates :timezone, :presence => true
end