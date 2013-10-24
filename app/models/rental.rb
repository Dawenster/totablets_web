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

			# headers = {
			# 	"Accept" => "*/*",
			# 	"Accept-Encoding" => "gzip,deflate,sdch",
			# 	"Accept-Language" => "en-US,en;q=0.8",
			# 	"Cache-Control" => "no-cache",
			# 	"Connection" => "keep-alive",
			# 	"Content-Length" => "61",
			# 	"Content-Type" => "application/x-www-form-urlencoded",
			# 	"Cookie" => "Cookie:__cfduid=d633538b4ad746e8c35b889a46ba9cb1e1373738581; registered=true; dash_auth=MOKTz0VWuWTwwjeCsosumevmZ1ZczNtTBiQo_HhtsGtfnmUmyJx17csAvm21FhoLXd7kprH_cpL49r52-uPlpfhtuId1V-2DAYRu6ysnW7KSW9NwgDA3K46IKOx1o38ZbxM0hNTbC-NUJIC0HyQB-xjZW8; BAYEUX_BROWSER=d72117eov5hn3naq4hlrddpo816ht; __utma=249374488.1268959068.1373740322.1379872680.1379885871.80; __utmb=249374488.9.10.1379885871; __utmc=249374488; __utmz=249374488.1379558262.68.22.utmcsr=account.meraki.com|utmccn=(referral)|utmcmd=referral|utmcct=/secure/login/dashboard_login; _session_id=71f021a5c26e05eaec20ea9e75bb45f9",
			# 	"Host" => "n38.meraki.com",
			# 	"Origin" => "https://n38.meraki.com",
			# 	"Pragma" => "no-cache",
			# 	"Referer" => "https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/configure/apps",
			# 	"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.76 Safari/537.36",
			# 	"X-CSRF-Token" => "825sHfjZIzDE4T7hm75kUifOm8yzTudPg8u/+5v8Jp0=",
			# 	"X-Requested-With" => "XMLHttpRequest"
			# }

			# gmail_app_id = "584342051651326340"
			# facebook_app_id = "584342051651324334"
			# twitter_app_id = "584342051651326341"
			# skype_app_id = "584342051651324335"

			# delete_app_post_path = "https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/configure/pcc_uninstall_app_from_clients"

			# # App refresh
			# a.post("https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/pcc/update_app_list/#{device.meraki_client_id}", {}, headers)

			# sleep(10)

			# # Delete Gmail app
			# a.post(delete_app_post_path, { "client_ids[]" => device.meraki_client_id, "app_id" => gmail_app_id }, headers)
			# sleep(1)

			# # Delete Facebook app
			# a.post(delete_app_post_path, { "client_ids[]" => device.meraki_client_id, "app_id" => facebook_app_id }, headers)
			# sleep(1)

			# # Delete Twitter app
			# a.post(delete_app_post_path, { "client_ids[]" => device.meraki_client_id, "app_id" => twitter_app_id }, headers)
			# sleep(1)

			# # Delete Skype app
			# a.post(delete_app_post_path, { "client_ids[]" => device.meraki_client_id, "app_id" => skype_app_id }, headers)
			# sleep(1)

			# # Client check in
			# a.post("https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/pcc/mdm_notify_now/#{device.meraki_client_id}", {}, headers)

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

	def self.install_apps(device_name)
		# device = Device.find_by_name(device_name)

		# a = Mechanize.new
		# a.get('https://account.meraki.com/secure/login/dashboard_login') do |page|

		#   my_page = page.form_with(:action => 'https://account.meraki.com/login/login') do |f|
		#     f.email = ENV['MERAKI_EMAIL']
		#     f.password = ENV['MERAKI_PASSWORD']
		#   end.click_button

		# 	headers = {
		# 		"Accept" => "*/*",
		# 		"Accept-Encoding" => "gzip,deflate,sdch",
		# 		"Accept-Language" => "en-US,en;q=0.8",
		# 		"Cache-Control" => "no-cache",
		# 		"Connection" => "keep-alive",
		# 		# "Content-Length" => "1193",
		# 		"Content-Type" => "application/x-www-form-urlencoded",
		# 		"Cookie" => "__cfduid=d633538b4ad746e8c35b889a46ba9cb1e1373738581; BAYEUX_BROWSER=d72117eov5hn3naq4hlrddpo816ht; registered=true; dash_auth=MOzl3Y4kWtzZkIXz7R2byb4IJcIAa-ozVtm2_90R4WGkepXLqTkEed881mDVMuqNJ5XVm9zDuR-KCu7xD680ViTHDesodJUZC9HGnn4Vf8wHa2OXu-7n0YuyoIYQLyazAcKkAufJ2wufwRuq9YKFpbqmdE; __utma=249374488.1268959068.1373740322.1379993518.1380086560.84; __utmb=249374488.18.10.1380086560; __utmc=249374488; __utmz=249374488.1380086560.84.24.utmcsr=account.meraki.com|utmccn=(referral)|utmcmd=referral|utmcct=/secure/login/dashboard_login; _session_id=16ec8fd95f0ce66dd704e15c3be56e9a",
		# 		"Host" => "n38.meraki.com",
		# 		"Origin" => "https://n38.meraki.com",
		# 		"Pragma" => "no-cache",
		# 		"Referer" => "https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/configure/apps",
		# 		"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.76 Safari/537.36",
		# 		"X-CSRF-Token" => "TBrsR/jV2qo3yCmBBEz6BQXFNCSqCanhOwE4DKVF0OM=",
		# 		"X-Requested-With" => "XMLHttpRequest"
		# 	}

		# 	gmail_app_id = "584342051651326340"
		# 	facebook_app_id = "584342051651324334"
		# 	twitter_app_id = "584342051651326341"
		# 	skype_app_id = "584342051651324335"

		# 	install_app_post_path = "https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/pcc/install_managed_app/#{device.meraki_client_id}"

		# 	# App refresh
		# 	a.post("https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/pcc/update_app_list/#{device.meraki_client_id}", {}, headers)

		# 	# Installing Gmail
		# 	a.post("#{install_app_post_path}?app=#{gmail_app_id}", { "app" => gmail_app_id }, headers)

		# 	# Client check in
		# 	a.post("https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/pcc/mdm_notify_now/#{device.meraki_client_id}", {}, headers)

		# 	# Installing Facebook
		# 	a.post("#{install_app_post_path}?app=#{facebook_app_id}", { "app" => facebook_app_id }, headers)

		# 	# Client check in
		# 	a.post("https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/pcc/mdm_notify_now/#{device.meraki_client_id}", {}, headers)

		# 	# Installing Twitter
		# 	a.post("#{install_app_post_path}?app=#{twitter_app_id}", { "app" => twitter_app_id }, headers)

		# 	# Client check in
		# 	a.post("https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/pcc/mdm_notify_now/#{device.meraki_client_id}", {}, headers)

		# 	# Installing Skype
		# 	a.post("#{install_app_post_path}?app=#{skype_app_id}", { "app" => skype_app_id }, headers)
		# end
	end

	def self.manage_single_app_profile(command, device_id)
		device = Device.find(device_id)
		payload = <<-eos
			<DeviceInfo xmlns="http://www.air-watch.com/servicemodel/resources">
			  <Udid>#{device.udid}</Udid>
			</DeviceInfo>
		eos
		auth = "Basic ZGF2aWRAdG90YWJsZXRzLmNvbTpBc2RmMTIzNA=="
		header = { :content_type => :xml, "aw-tenant-code" => "1LSVS4BQAAG5A4TQCFQA", :authorization => auth, :accept => :xml }
    response = RestClient.post("https://cn239.awmdm.com/API/v1/mdm/profiles/734/#{command}", payload, header)

		apps_requiring_login = [274, 275, 276, 277, 278] # Gmail, Facebook, Twitter, Skype, LinkedIn
		apps_requiring_login.each do |app_id|
			sleep 1
			if command == "remove" # If removing single app mode, install apps
				Rental.manage_app("install", app_id, payload, header)
			else # If installing single app mode, delete apps
				Rental.manage_app("uninstall", app_id, payload, header)
			end
		end
	end

	def self.manage_app(command, app_id, payload, header)
		response = RestClient.post("https://cn239.awmdm.com/API/v1/mam/apps/public/#{app_id}/#{command}", payload, header)
	end

	def self.stop_existing_rentals(device)
		ongoing_rentals = device.rentals.select{ |rental| !rental.returned }
		ongoing_rentals.each do |rental|
			rental.update_attributes(:end_date => Time.now, :finished => true, :returned => true)
		end
	end
end