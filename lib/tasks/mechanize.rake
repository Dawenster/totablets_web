require 'rubygems'
require 'mechanize'

task :lock_app => :environment do
	Rental.lock_app
end

task :unlock_app => :environment do
	Rental.unlock_app
end