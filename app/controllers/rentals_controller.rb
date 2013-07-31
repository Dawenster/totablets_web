class RentalsController < ApplicationController

	def create
		Stripe.api_key = ENV['STRIPE_SECRET_KEY']

		# Get the credit card details submitted by the form
		token = params[:stripe_token]
		totablets_customer = Customer.find_by_email(params[:email])

		begin

			if totablets_customer
				# Charge the repeat customer instead of the card
				Stripe::Charge.create(
			    :amount => params[:grand_total], # in cents
			    :currency => params[:currency].downcase,
			    :customer => totablets_customer.stripe_customer_id,
			    :description => "#{params[:location]} iPad rental: #{params[:days]} days at $#{params[:rate].to_i / 100}/day (plus #{params[:tax_names]})"
				)
			else
				# Create a Stripe customer
				stripe_customer = Stripe::Customer.create(
				  :card => token,
				  :email => params[:email]
				)

				# Charge the new customer instead of the card
				Stripe::Charge.create(
			    :amount => params[:grand_total], # in cents
			    :currency => params[:currency].downcase,
			    :customer => stripe_customer.id,
			    :description => "#{params[:location]} iPad rental: #{params[:days]} days at $#{params[:rate].to_i / 100}/day (plus #{params[:tax_names]})"
				)

				stripe_customer_id = stripe_customer.id
			end

		rescue Stripe::CardError => e # Since it's a decline, Stripe::CardError will be caught
		  body = e.json_body
		  err  = body[:error]
		  message = "#{err[:message]} No charge made - please check your credit card information."
		  puts message
		  render :json => { :stripe_error =>  message } and return
		rescue Stripe::InvalidRequestError => e # Invalid parameters were supplied to Stripe's API
		  body = e.json_body
		  err  = body[:error]
		  message = "#{err[:message]} No charge made.  Please notify hotel staff (Params Error)."
		  puts message
		  render :json => { :stripe_error =>  message } and return
		rescue Stripe::AuthenticationError => e # Authentication with Stripe's API failed (maybe you changed API keys recently)
		  body = e.json_body
		  err  = body[:error]
		  message = "#{err[:message]} No charge made.  Please notify hotel staff (API Error)."
		  puts message
		  render :json => { :stripe_error =>  message } and return
		rescue Stripe::APIConnectionError => e # Network communication with Stripe failed
		  body = e.json_body
		  err  = body[:error]
		  message = "#{err[:message]} No charge made.  Please notify hotel staff (Network Error)."
		  puts message
		  render :json => { :stripe_error =>  message } and return
		rescue Stripe::StripeError => e # Display a very generic error to the user, and maybe send yourself an email
		  body = e.json_body
		  err  = body[:error]
		  message = "#{err[:message]} No charge made.  Please notify hotel staff (Generic Error)."
		  puts message
		  render :json => { :stripe_error =>  message } and return
		rescue => e # Something else happened, completely unrelated to Stripe
		  body = e.json_body
		  err  = body[:error]
		  message = "#{err[:message]} No charge made.  Please notify hotel staff (error not related to payment)."
		  puts message
		  render :json => { :stripe_error =>  message } and return
		end

		unless totablets_customer
			totablets_customer = Customer.create(
				:name => params[:name],
				:email => params[:email],
				:stripe_token => params[:stripe_token],
				:stripe_customer_id => stripe_customer_id
			)
			puts "Created customer: #{totablets_customer.name} - #{totablets_customer.email}"
		end

		Rental.unlock_app

		render :json => { :stripe_error => "None" }
	end

	def capture_customer_data
		sleep 10
		totablets_customer = Customer.find_by_email(params[:email])

		if totablets_customer
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
		else
			render :json => { :message => "No customer created yet." }
		end
	end
end