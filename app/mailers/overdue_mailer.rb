class OverdueMailer < ActionMailer::Base
	default from: 'TO Tablets Crime Watch <info@totablets.com>'

	def rental_overdue(rental_id)
    @rental = Rental.find(rental_id)
    @customer = @rental.customer
    @device = @rental.device
    @location = @rental.location

    mail(to: ["dstwen@gmail.com", "frank.wang.xiao@gmail.com"], subject: "OVERDUE RENTAL @ #{@location.name}")
  end
end