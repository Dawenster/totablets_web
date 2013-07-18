class CreateRentalRecordsJob
	extend HerokuAutoScaler::AutoScaling

  @queue = :create_rental_records

  def self.queue
  	:create_rental_records
  end

  def self.perform(args, stripe_customer_id)
    totablets_customer = Customer.find_by_email(args["email"])

    unless totablets_customer
			totablets_customer = Customer.create(
				:name => args["name"],
				:email => args["email"],
				:stripe_token => args["stripe_token"],
				:stripe_customer_id => stripe_customer_id
			)
			puts "Created customer: #{totablets_customer.name} - #{totablets_customer.email}"
		end

		location = Location.find_by_name(args["location"].split(", ").first)
		start_date = DateTime.strptime(args["start_date"].gsub("  0000",""), "%Y-%m-%d %H:%M:%S")
		end_date = DateTime.strptime(args["end_date"].gsub("  0000",""), "%Y-%m-%d %H:%M:%S")

		rental = Rental.create(
			:device_name => args["device_name"],
      :location_detail => args["location_detail"],
      :days => args["days"].to_i,
      :start_date => start_date,
      :end_date => end_date,
      :rate => args["rate"].to_i,
      :subtotal => args["subtotal"].to_i,
      :tax_rate => args["tax_percentage"].to_i,
      :tax_amount => args["tax_amount"].to_i,
      :grand_total => args["grand_total"].to_i,
			:currency => args["currency"],
      :customer => totablets_customer,
      :location => location
		)

		args["tax_names"].split(" and ").each do |tax_name|
			tax = Tax.find_by_name(tax_name)
			tax.rentals << rental
		end

		self.after_perform_scale_down
  end
end