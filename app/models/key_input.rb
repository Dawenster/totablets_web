class KeyInput < ActiveRecord::Base
	attr_accessible :rate, :pre_auth_amount, :terms_and_conditions

	validates :rate, :presence => true
	validates :pre_auth_amount, :presence => true
	validates :terms_and_conditions, :presence => true
end