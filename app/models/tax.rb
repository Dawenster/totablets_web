class Tax < ActiveRecord::Base
	attr_accessible :name, :rate

	has_and_belongs_to_many :rentals
	has_and_belongs_to_many :locations

	validates :name, :presence => true
	validates :rate, :presence => true
end