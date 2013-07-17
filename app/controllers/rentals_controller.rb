class RentalsController < ApplicationController
	def create
		Stripe.api_key = ENV['STRIPE_SECRET_KEY']

		# Get the credit card details submitted by the form
		token = params[:stripe_token]

		# Create a Stripe customer
		stripe_customer = Stripe::Customer.create(
		  :card => token,
		  :description => params[:email]
		)

		# Charge the customer instead of the card
		Stripe::Charge.create(
	    :amount => params[:grand_total], # in cents
	    :currency => params[:currency].downcase,
	    :customer => stripe_customer.id
		)

		# Resque.enqueue(CreateRentalRecordsJob, params, stripe_customer.id)

		render :json => { :stripe_customer => stripe_customer.id }
	end
end