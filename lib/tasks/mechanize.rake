require 'rubygems'
require 'mechanize'

task :lock_app, [:device_name] => :environment do |t, args|
	Rental.lock_app(args[:device_name])
end

task :unlock_app, [:device_name, :opts] => :environment do |t, args|
	Rental.unlock_app(args[:device_name], args[:opts])
end

task :check_completed_rentals => :environment do
	rentals = Rental.where("end_date < '#{Time.now.utc}'").where("finished is null")
	rentals.each do |rental|
		device = rental.device
		Rental.manage_single_app_profile("install", device.id, {})
		rental.update_attributes(:finished => true)
	end

	overdue_rentals = Rental.where(:finished => true, :returned => false)
	overdue_rentals.each do |rental|
		OverdueMailer.rental_overdue(rental.id).deliver unless rental.returned
	end
end

task :check_overdue => :environment do
	rentals = Rental.where(:finished => true, :returned => false)
	rentals.each do |rental|
		OverdueMailer.rental_overdue(rental.id).deliver unless rental.returned
	end
end