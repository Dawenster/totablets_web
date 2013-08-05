class CustomersController < ApplicationController
	def index
		@customers = Customer.order("created_at DESC")
	end

	def show
		@customer = Customer.find(params[:id])
	end
end