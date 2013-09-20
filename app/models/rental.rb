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

		 #  headers = {
			#   "Accept" => "application/json, text/javascript, */*; q=0.01",
			# 	"Accept-Encoding" => "gzip,deflate,sdch",
			# 	"Accept-Language" => "en-US,en;q=0.8",
			# 	"Content-Type" => "application/json; charset=utf-8",
			# 	"X-Requested-With" => "XMLHttpRequest"
			# }

		 #  a.post("https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/pcc/mdm_clear_passcode/584342051651324544", { "_ts" => 1377481330901 }, headers)

		  a.get("https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/configure/pcc_ios") do |settings_page|
			  settings_page.form_with(:action => '/Systems-Manager/n/xkWsDaM/manage/configure/update_pcc_ios') do |form|
			  	# puts "Before click: the box is #{form.checkbox_with(:id => 'profile_applock_enabled').checked ? "" : "un"}checked"
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

	def self.stop_existing_rentals(device)
		ongoing_rentals = device.rentals.select{ |rental| !rental.returned }
		ongoing_rentals.each do |rental|
			rental.update_attributes(:end_date => Time.now, :finished => true, :returned => true)
		end
	end
end