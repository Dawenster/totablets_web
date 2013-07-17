class Tax < ActiveRecord::Base
	attr_accessible :name, :rate

	has_many :rentals
end