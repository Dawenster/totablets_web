class Rental < ActiveRecord::Base
	attr_accessible :device_name, :location_detail, :days, :start_date, :end_date, :rate, :subtotal, :tax_rate, :tax_amount, :grand_total,
									:currency, :customer, :location

	belongs_to :customer
	belongs_to :location
	has_one :device
	has_and_belongs_to_many :taxes, :class_name => 'Tax'

	def self.lock_app
		a = Mechanize.new
		a.get('https://account.meraki.com/secure/login/dashboard_login') do |page|

		  my_page = page.form_with(:action => 'https://account.meraki.com/login/login') do |f|
		    f.email = "dstwen@gmail.com"
		    f.password = "Wahowe100!"
		  end.click_button

		  a.get("https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/configure/pcc_ios") do |settings_page|
			  settings_page.form_with(:action => '/Systems-Manager/n/xkWsDaM/manage/configure/update_pcc_ios') do |form|
			  	# puts "Before click: the box is #{form.checkbox_with(:id => 'profile_applock_enabled').checked ? "" : "un"}checked"
			  	form.checkbox_with(:id => "profile_enable_restrictions").check
			  	form["profile[id]"] = "584342051651322821"
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

	def self.unlock_app
		a = Mechanize.new
		a.get('https://account.meraki.com/secure/login/dashboard_login') do |page|

		  my_page = page.form_with(:action => 'https://account.meraki.com/login/login') do |f|
		    f.email = "dstwen@gmail.com"
		    f.password = "Wahowe100!"
		  end.click_button

		  a.get("https://n38.meraki.com/Systems-Manager/n/xkWsDaM/manage/configure/pcc_ios") do |settings_page|
			  settings_page.form_with(:action => '/Systems-Manager/n/xkWsDaM/manage/configure/update_pcc_ios') do |form|
			  	form.checkbox_with(:id => "profile_enable_restrictions").check
			  	form["profile[id]"] = "584342051651322821"
				  form.checkbox_with(:id => "profile_applock_enabled").uncheck
				  form["profile[applock][enabled]"] = false
			  	form.checkbox_with(:id => "profile_proxy_enabled").uncheck
			  	after_save_page = form.submit
			  	puts after_save_page.body
				end
			end
		end
	end
end