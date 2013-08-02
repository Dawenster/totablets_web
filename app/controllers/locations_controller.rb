class LocationsController < ApplicationController
	def index
		@locations = Location.order("name ASC")
	end

	def show
		@location = Location.find(params[:id])
	end

	def new
		@location = Location.new
	end

	def create
		location = Location.new(params)
		if location.save

		else

		end
	end

	def edit
		@location = Location.find(params[:id])
	end

	def update
		location = Location.find(params[:id])
		location.assign_attributes(params)
		if location.save

		else

		end
	end

	def delete
		Location.find(params[:id]).destroy
	end
end