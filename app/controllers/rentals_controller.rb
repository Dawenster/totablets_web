class RentalsController < ApplicationController
	# extend HerokuAutoScaler::AutoScaling
	
	def create
		Stripe.api_key = ENV['STRIPE_SECRET_KEY']

		# Get the credit card details submitted by the form
		token = params[:stripe_token]

		totablets_customer = Customer.find_by_email(params[:email])

		if totablets_customer
			# Charge the repeat customer instead of the card
			Stripe::Charge.create(
		    :amount => params[:grand_total], # in cents
		    :currency => params[:currency].downcase,
		    :customer => totablets_customer.stripe_customer_id
			)

			stripe_customer_id = totablets_customer.stripe_customer_id
		else
			# Create a Stripe customer
			stripe_customer = Stripe::Customer.create(
			  :card => token,
			  :description => params[:email]
			)

			# Charge the new customer instead of the card
			Stripe::Charge.create(
		    :amount => params[:grand_total], # in cents
		    :currency => params[:currency].downcase,
		    :customer => stripe_customer.id
			)

			stripe_customer_id = stripe_customer.id
		end

		Resque.enqueue(CreateRentalRecordsJob, params, stripe_customer_id)
		# self.after_enqueue_scale_up

		render :json => { :stripe_customer => stripe_customer_id }
	end
end