class CreateRentalRecordsJob
  
  @queue = :create_rental_records

  def self.perform(args, stripe_customer_id)
    # Create a TO Tablets customer
		totablets_customer = Customer.create(
			:name => args[:name], 
			:email => args[:email], 
			:stripe_token => args[:stripe_token], 
			:stripe_customer_id => stripe_customer_id
		)
  end
end