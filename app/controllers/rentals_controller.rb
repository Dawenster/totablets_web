class RentalsController < ApplicationController

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

			# Create local record
			totablets_customer = Customer.create(
				:name => params[:name],
				:email => params[:email],
				:stripe_token => params[:stripe_token],
				:stripe_customer_id => stripe_customer.id
			)

			puts "Created customer: #{totablets_customer.name} - #{totablets_customer.email}"
		end

		render :json => { :stripe_customer => totablets_customer.stripe_customer_id }
	end

	def capture_customer_data
		totablets_customer = Customer.find_or_create_by_email(params[:email])
		location = Location.find_by_name(params["location"].split(", ").first)
		start_date = DateTime.strptime(params["start_date"].gsub("  0000",""), "%Y-%m-%d %H:%M:%S")
		end_date = DateTime.strptime(params["end_date"].gsub("  0000",""), "%Y-%m-%d %H:%M:%S")

		rental = Rental.create(
			:device_name => params["device_name"],
      :location_detail => params["location_detail"],
      :days => params["days"].to_i,
      :start_date => start_date,
      :end_date => end_date,
      :rate => params["rate"].to_i,
      :subtotal => params["subtotal"].to_i,
      :tax_rate => params["tax_percentage"].to_i,
      :tax_amount => params["tax_amount"].to_i,
      :grand_total => params["grand_total"].to_i,
			:currency => params["currency"],
      :customer => totablets_customer,
      :location => location
		)

		params["tax_names"].split(" and ").each do |tax_name|
			tax = Tax.find_by_name(tax_name)
			tax.rentals << rental
		end

		render :json => { :rental => rental.id }
	end
end