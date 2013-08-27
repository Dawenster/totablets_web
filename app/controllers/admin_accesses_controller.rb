class AdminAccessesController < ApplicationController
	http_basic_authenticate_with :name => ENV['ADMIN_NAME'], :password => ENV['ADMIN_PASSWORD']
	
	def index
		@admin_accesses = AdminAccess.order("created_at DESC").paginate(page: params[:page], :per_page => 25)
		@time_differences = {
			"PST" => 0,
			"MST" => 1,
			"CST" => 2,
			"EST" => 3
		}
		Time.zone = "Pacific Time (US & Canada)"
	end
end