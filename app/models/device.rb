class Device < ActiveRecord::Base
	attr_accessible :name, :profile_value, :device_type, :location, :location_id

	has_many :rentals
	belongs_to :location

	validates :name, :presence => true
	validates :profile_value, :presence => true
	validates :device_type, :presence => true
end