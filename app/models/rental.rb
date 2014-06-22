class Rental < ActiveRecord::Base

	attr_accessible :device_name, :location_detail, :days, :start_date, :end_date, :rate, :subtotal, :tax_rate, :tax_amount,
									:grand_total, :currency, :customer, :location, :device, :device_id, :finished, :stripe_rental_charge_id,
									:terms_and_conditions, :demo, :returned

	belongs_to :customer
	belongs_to :location
	belongs_to :device
	has_one :pre_auth
	has_and_belongs_to_many :taxes, :class_name => 'Tax'

	def self.lock_app(device_name)
		device = Device.find_by_name(device_name)

		a = Mechanize.new
		a.get('https://account.meraki.com/secure/login/dashboard_login') do |page|

			my_page = page.form_with(:action => 'https://account.meraki.com/login/login') do |f|
				f.email = ENV['MERAKI_EMAIL']
		    f.password = ENV['MERAKI_PASSWORD']
		  end.click_button

			# Lock device
			a.get("https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/configure/pcc_ios") do |settings_page|
			  settings_page.form_with(:action => '/Systems-Manager/n/xkWsDaM/manage/configure/update_pcc_ios') do |form|
			  	form.checkbox_with(:id => "profile_enable_restrictions").check
			  	form["profile[id]"] = device.profile_value
				  form.checkbox_with(:id => "profile_applock_enabled").check
				  form["profile[applock][enabled]"] = true
				  form.field_with(:id => 'profile_applock_app_select').options[4].click
				  form["profile[applock][bundle_identifier]"] = "com.totablets.TOTablets"
				  form.checkbox_with(:id => "profile_proxy_enabled").uncheck
				  after_save_page = form.submit
			  	puts after_save_page.body
				end
			end
		end
	end

	def self.unlock_app(device_name, opts={})
		device = Device.find_by_name(device_name)

		a = Mechanize.new
		a.get('https://account.meraki.com/secure/login/dashboard_login') do |page|

		  my_page = page.form_with(:action => 'https://account.meraki.com/login/login') do |f|
		    f.email = ENV['MERAKI_EMAIL']
		    f.password = ENV['MERAKI_PASSWORD']
		  end.click_button

		  # Unlock device
		  a.get("https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/configure/pcc_ios") do |settings_page|
			  settings_page.form_with(:action => '/Systems-Manager/n/xkWsDaM/manage/configure/update_pcc_ios') do |form|
			  	form.checkbox_with(:id => "profile_enable_restrictions").check
			  	form["profile[id]"] = device.profile_value
				  form.checkbox_with(:id => "profile_applock_enabled").uncheck
				  form["profile[applock][enabled]"] = false
			  	form.checkbox_with(:id => "profile_proxy_enabled").uncheck
			  	if opts[:restrict_content] == "yes"
				  	form.checkbox_with(:id => "profile_restrictions_allow_explicit_content").uncheck
				  	form.checkbox_with(:id => "profile_restrictions_allow_safari").uncheck
				  	form["profile[restrictions][rating_movies]"] = "300"
				  	form["profile[restrictions][rating_tv_shows]"] = "500"
				  	form["profile[restrictions][rating_apps]"] = "300"
				  else
				  	form.checkbox_with(:id => "profile_restrictions_allow_explicit_content").check
				  	form.checkbox_with(:id => "profile_restrictions_allow_safari").check
				  	form["profile[restrictions][rating_movies]"] = "1000"
				  	form["profile[restrictions][rating_tv_shows]"] = "1000"
				  	form["profile[restrictions][rating_apps]"] = "1000"
				  end
			  	after_save_page = form.submit
			  	puts after_save_page.body
				end
			end
		end
	end

	def self.manage_single_app_profile(command, device_id, opts)
		device = Device.find(device_id)
		payload = <<-eos
			<DeviceInfo xmlns="http://www.air-watch.com/servicemodel/resources">
			  <Udid>#{device.udid}</Udid>
			</DeviceInfo>
		eos
		# auth = "Basic ZGF2aWRAdG90YWJsZXRzLmNvbTpBc2RmMTIzNA=="
		auth = "Basic ZGF2aWRAdG90YWJsZXRzLmNvbTpXYWhvd2UyMDAh"
		header = { :content_type => :xml, "aw-tenant-code" => "1LSVS4BQAAG5A4TQCFQA", :authorization => auth, :accept => :xml }

		# Order matters when installing / uninstalling apps
		if command == "remove"
	    RestClient.post("https://cn239.awmdm.com/API/v1/mdm/profiles/734/#{command}", payload, header) if Rental.profile_installed?(device, header, 734)
			Rental.manage_apps(device, command, payload, header)
			sleep 1
	    if opts[:restrict_content] == "yes"
	    	# Install adult restriction profile
		    RestClient.post("https://cn239.awmdm.com/API/v1/mdm/profiles/733/install", payload, header) unless Rental.profile_installed?(device, header, 733)
		    # sleep 1
				# Install Mobicip
				# Rental.manage_app("install", 565, payload, header)
			else
				# Install Google Chrome
				Rental.manage_app("install", 564, payload, header)
			end
		else
			Rental.clear_passcode(device, header)
			sleep 1
			Rental.manage_apps(device, command, payload, header)
			RestClient.post("https://cn239.awmdm.com/API/v1/mdm/profiles/734/#{command}", payload, header) unless Rental.profile_installed?(device, header, 734)
			sleep 1
			# Remove adult content profile if it is there
			RestClient.post("https://cn239.awmdm.com/API/v1/mdm/profiles/733/remove", payload, header) if Rental.profile_installed?(device, header, 733)
			sleep 1
			# Remove either Chrome or Mobicip
			Rental.manage_app("uninstall", 564, payload, header) if Rental.app_installed?(device, 564, header)
			# Rental.manage_app("uninstall", 565, payload, header) if Rental.app_installed?(device, 565, header)
		end
	end

	def self.manage_apps(device, command, payload, header)
		apps_requiring_login = [274, 275, 276, 277, 278] # Gmail, Facebook, Twitter, Skype, LinkedIn
		apps_requiring_login.each do |app_id|
			if command == "remove" # If removing single app mode, install apps
				sleep 1
				Rental.manage_app("install", app_id, payload, header) unless Rental.app_installed?(device, app_id, header)
			else # If installing single app mode, delete apps
				Rental.manage_app("uninstall", app_id, payload, header) if Rental.app_installed?(device, app_id, header)
				sleep 1
			end
		end
	end

	def self.manage_app(command, app_id, payload, header)
		RestClient.post("https://cn239.awmdm.com/API/v1/mam/apps/public/#{app_id}/#{command}", payload, header)
	end

	def self.stop_existing_rentals(device)
		ongoing_rentals = device.rentals.select{ |rental| !rental.returned }
		ongoing_rentals.each do |rental|
			rental.update_attributes(:end_date => Time.now, :finished => true, :returned => true)
		end
	end

	def self.clear_passcode(device, header)
		RestClient.post("https://cn239.awmdm.com/API/v1/mdm/devices/udid/#{device.udid}/clearpasscode", {}, header)
	end

	def self.profile_installed?(device, header, profile_id)
		response = RestClient.get("https://cn239.awmdm.com/API/v1/mdm/devices/udid/#{device.udid}/profiles?page=0&pagesize=10", header)
		response_hash = Hash.from_xml response
		response_hash["DeviceProfileSearchResult"]["DeviceProfiles"].each do |profile|
			next unless profile["Id"] == profile_id.to_s
			if profile["Status"] == "confirmedinstall"
				return true
			end
		end
		return false
	end

	def self.app_installed?(device, app_id, header)
		response = RestClient.get("https://cn239.awmdm.com/API/v1/mdm/devices/udid/#{device.udid}/apps?page=0&pagesize=200", header)
		response_hash = Hash.from_xml response
		response_hash["DeviceAppsResult"]["DeviceApps"].each do |profile|
			next unless profile["Id"] == app_id.to_s
			if profile["Status"] == "installed"
				return true
			end
		end
		return false
	end
end