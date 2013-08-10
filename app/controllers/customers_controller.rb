class CustomersController < ApplicationController
	http_basic_authenticate_with :name => ENV['ADMIN_NAME'], :password => ENV['ADMIN_PASSWORD']
	
	def index
		@customers = Customer.order("created_at DESC")
	end

	def show
		@customer = Customer.find(params[:id])
	end
end