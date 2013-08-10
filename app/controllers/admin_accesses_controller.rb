class AdminAccessesController < ApplicationController
	http_basic_authenticate_with :name => ENV['ADMIN_NAME'], :password => ENV['ADMIN_PASSWORD']
	
	def index
		@admin_accesses = AdminAccess.order("created_at DESC")
	end
end