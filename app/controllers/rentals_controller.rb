class RentalsController < ApplicationController
	http_basic_authenticate_with :name => ENV['ADMIN_NAME'], :password => ENV['ADMIN_PASSWORD'], :only => [:index, :show]

	def index
		@rentals = Rental.order("start_date DESC").paginate(page: params[:page], :per_page => 25)
	end

	def show
		@rental = Rental.find(params[:id])
		time_differences = {
			"PST" => 0,
			"MST" => 1,
			"CST" => 2,
			"EST" => 3
		}
		@hour_differential = time_differences[@rental.location.timezone]

		Time.zone = "Pacific Time (US & Canada)"
		# in_dst = Time.zone.local(Time.now.year, Time.now.month, Time.now.day, Time.now.hour, Time.now.min, 0).dst?

		# @hour_differential -= 1 if in_dst
	end

	def location_info
		device = Device.find_by_name(params[:ipad_name])
		device = Device.first(:order => "RANDOM()") if device.nil?
		location = device.location
		taxes = {}
		location.taxes.each { |tax| taxes[tax.name] = tax.rate }
		render :json => {
			"location_name" => "#{location.name}, #{location.city}",
			"currency" => location.currency,
			"rental_fee" => KeyInput.last.rate,
			"pre_auth_amount" => KeyInput.last.pre_auth_amount,
			"publishable_key" => ENV['STRIPE_PUBLISHABLE_KEY'],
			"taxes" => taxes,
			"admin_password" => device.admin_password,
			"terms_and_conditions" => KeyInput.last.terms_and_conditions
		}
	end

	def create
		Stripe.api_key = ENV['STRIPE_SECRET_KEY']

		# Get the credit card details submitted by the form
		token = params[:stripe_token]
		totablets_customer = Customer.find_by_email(params[:email].downcase)

		begin
			pre_auth_amount = params[:pre_auth_amount].to_i

			if totablets_customer
				# Charge the repeat customer instead of the card
				rental_charge = Stripe::Charge.create(
			    :amount => params[:grand_total], # in cents
			    :currency => params[:currency].downcase,
			    :customer => totablets_customer.stripe_customer_id,
			    :description => "#{params[:location]} iPad rental: #{params[:days]} days at $#{params[:rate].to_i / 100}/day (plus #{params[:tax_names]})"
				)

				# Charge a damage / theft pre-authorization on the card
				pre_auth = Stripe::Charge.create(
			    :amount => pre_auth_amount, # in cents
			    :currency => params[:currency].downcase,
			    :customer => totablets_customer.stripe_customer_id,
			    :description => "PRE-AUTHORIZATION: #{params[:location]} iPad rental: #{params[:days]} days at $#{params[:rate].to_i / 100}/day (plus #{params[:tax_names]})",
			    :capture => false
				)
			else
				# Create a Stripe customer
				stripe_customer = Stripe::Customer.create(
				  :card => token,
				  :email => params[:email]
				)

				# Charge the new customer instead of the card
				rental_charge = Stripe::Charge.create(
			    :amount => params[:grand_total], # in cents
			    :currency => params[:currency].downcase,
			    :customer => stripe_customer.id,
			    :description => "#{params[:location]} iPad rental: #{params[:days]} days at $#{params[:rate].to_i / 100}/day (plus #{params[:tax_names]})"
				)

				# Charge a damage / theft pre-authorization on the card
				pre_auth = Stripe::Charge.create(
			    :amount => pre_auth_amount, # in cents
			    :currency => params[:currency].downcase,
			    :customer => stripe_customer.id,
			    :description => "PRE-AUTHORIZATION: #{params[:location]} iPad rental: #{params[:days]} days at $#{params[:rate].to_i / 100}/day (plus #{params[:tax_names]})",
			    :capture => false
				)
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
				:email => params[:email].downcase,
				:stripe_token => params[:stripe_token],
				:stripe_customer_id => stripe_customer.id
			)
			puts "Created customer: #{totablets_customer.name} - #{totablets_customer.email}"
		end

		opts = {
			:restrict_content => params["restrict_content"]
		}

		Rental.unlock_app(params["device_name"], opts)

		render :json => {
			:stripe_error => "None", 
			:rental_charge_id => rental_charge.id, 
			:pre_auth_id => pre_auth.id,
			:pre_auth_amount => pre_auth.amount
		}
	end

	def capture_customer_data
		totablets_customer = Customer.find_by_email(params[:email].downcase)

		if totablets_customer
			location = Location.find_by_name(params["location"].split(", ").first)
			device = Device.find_by_name(params["device_name"])
			start_date = DateTime.strptime(params["start_date"].gsub("  0000",""), "%Y-%m-%d %H:%M:%S")
			end_date = DateTime.strptime(params["end_date"].gsub("  0000",""), "%Y-%m-%d %H:%M:%S")

			Rental.stop_existing_rentals(device)

			rental = Rental.create(
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
				:stripe_rental_charge_id => params["rental_charge_id"],
	      :customer => totablets_customer,
	      :location => location,
				:device => device,
				:terms_and_conditions => params["terms_and_conditions"]
			)

			PreAuth.create(
				:stripe_pre_auth_id => params["pre_auth_id"],
				:pre_auth_amount => params["pre_auth_amount"].to_i,
				:rental => rental
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

	def admin_command
		device = Device.find_by_name(params["ipad_name"])
		if params["command"] == "unlock"
			Rental.unlock_app(device.name)
		else
			Rental.stop_existing_rentals(device)
			Rental.lock_app(device.name)
		end
		unless params["origin"] == "finish_rental"
			AdminAccess.create(
				:device_name_during_access => device.name,
				:location_during_access => "#{device.location.name}, #{device.location.city}",
				:action => params["command"]
			)
		end
		render :json => { :command => params["command"] }
	end
end


















