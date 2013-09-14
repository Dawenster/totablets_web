class NotificationsController < ApplicationController
	def index
		@notifications = Notification.all
	end

	def new
		@notification = Notification.new
	end

	def create
		notification = Notification.new(params[:notification])
		if notification.save
			flash[:success] = "Notification ##{notification.id} has been successfully created."
			redirect_to notifications_path
		else
			flash.now[:errors] = "Gawd. Fill everything in correctly man."
			@notification = notification
			render "new"
		end
	end

	def edit
		@notification = Notification.find(params[:id])
	end

	def update
		notification = Notification.find(params[:id])
		notification.assign_attributes(params[:notification])
		if notification.save
			flash[:success] = "Notification ##{notification.id} has been updated."
			redirect_to notifications_path
		else
			flash.now[:errors] = "Gawd. Fill everything in correctly man."
			@notification = notification
			render "edit"
		end
	end

	def destroy
		notification = Notification.find(params[:id]).destroy
		flash[:success] = "Notification ##{notification.id} has been deleted."
		redirect_to notifications_path
	end
end