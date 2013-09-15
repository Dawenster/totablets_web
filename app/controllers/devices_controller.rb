class DevicesController < ApplicationController
	http_basic_authenticate_with :name => ENV['ADMIN_NAME'], :password => ENV['ADMIN_PASSWORD']

	def index
		@devices = Device.order("lower(name) ASC")
	end

	def new
		@device = Device.new
	end

	def create
		params[:device][:demo] = params[:device][:demo] == "Demo" ? true : false
		device = Device.new(params[:device])
		if device.save
			flash[:success] = "#{device.name} has been successfully created."
			redirect_to devices_path
		else
			flash.now[:errors] = "Gawd. Fill everything in man."
			@device = device
			render "new"
		end
	end

	def edit
		@device = Device.find(params[:id])
	end

	def update
		device = Device.find(params[:id])
		params[:device][:demo] = params[:device][:demo] == "Demo" ? true : false
		device.assign_attributes(params[:device])
		if device.save
			flash[:success] = "#{device.name} has been updated."
			redirect_to devices_path
		else
			flash.now[:errors] = "Gawd. Fill everything in man."
			@device = device
			render "edit"
		end
	end

	def destroy
		device = Device.find(params[:id]).destroy
		flash[:success] = "#{device.name} has been deleted."
		redirect_to devices_path
	end
end