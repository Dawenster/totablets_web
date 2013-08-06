class PreAuth < ActiveRecord::Base
	attr_accessible :stripe_pre_auth_id, :pre_auth_amount, :captured_amount, :description, :rental

	belongs_to :rental

	validates :stripe_pre_auth_id, :presence => true
	validates :pre_auth_amount, :presence => true
end