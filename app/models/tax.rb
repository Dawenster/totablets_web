class Tax < ActiveRecord::Base
	attr_accessible :name, :rate

	has_and_belongs_to_many :rentals
end