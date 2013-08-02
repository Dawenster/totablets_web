class LocationsController < ApplicationController
	http_basic_authenticate_with :name => ENV['ADMIN_NAME'], :password => ENV['ADMIN_PASSWORD']

	def index
		@locations = Location.order("lower(name) ASC")
	end

	def new
		@location = Location.new
	end

	def create
		location = Location.new(params[:location])
		if location.save
			flash[:success] = "#{location.name} has been successfully created."
			redirect_to locations_path
		else
			flash.now[:errors] = "Gawd. Fill everything in man."
			@location = location
			render "new"
		end
	end

	def edit
		@location = Location.find(params[:id])
	end

	def update
		location = Location.find(params[:id])
		location.assign_attributes(params[:location])
		if location.save
			flash[:success] = "#{location.name} has been updated."
			redirect_to locations_path
		else
			flash.now[:errors] = "Gawd. Fill everything in man."
			@location = location
			render "edit"
		end
	end

	def destroy
		location = Location.find(params[:id]).destroy
		flash[:success] = "#{location.name} has been deleted."
		redirect_to locations_path
	end
end