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
		Rental.lock_app(rental.device.name)
		rental.update_attributes(:finished => true)
	end
end