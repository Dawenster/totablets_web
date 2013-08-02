class Device < ActiveRecord::Base
	attr_accessible :name, :profile_value, :device_type, :location

	belongs_to :rentals
	has_one :location
end