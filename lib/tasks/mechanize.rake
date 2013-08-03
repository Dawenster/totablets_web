require 'rubygems'
require 'mechanize'

task :lock_app, [:profile_value] => :environment do |t, args|
	Rental.lock_app(args[:profile_value])
end

task :unlock_app, [:profile_value] => :environment do |t, args|
	Rental.unlock_app(args[:profile_value])
end