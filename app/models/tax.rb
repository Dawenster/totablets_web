class Tax < ActiveRecord::Base
	extend HerokuAutoScaler::AutoScaling
	
	attr_accessible :name, :rate

	has_and_belongs_to_many :rentals
end