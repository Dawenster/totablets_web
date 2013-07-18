class Customer < ActiveRecord::Base
	extend HerokuAutoScaler::AutoScaling
	
	attr_accessible :name, :email, :stripe_token, :stripe_customer_id

	has_many :rentals
	has_many :location
end