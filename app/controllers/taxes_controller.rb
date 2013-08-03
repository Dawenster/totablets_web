class TaxesController < ApplicationController
	http_basic_authenticate_with :name => ENV['ADMIN_NAME'], :password => ENV['ADMIN_PASSWORD']

	def index
		@taxes = Tax.order("lower(name) ASC")
	end

	def new
		@tax = Tax.new
	end

	def create
		tax = Tax.new(params[:tax])
		if tax.save
			flash[:success] = "#{tax.name} has been successfully created."
			redirect_to taxes_path
		else
			flash.now[:errors] = "Gawd. Fill everything in man."
			@tax = tax
			render "new"
		end
	end

	def edit
		@tax = Tax.find(params[:id])
	end

	def update
		tax = Tax.find(params[:id])
		tax.assign_attributes(params[:tax])
		if tax.save
			flash[:success] = "#{tax.name} has been updated."
			redirect_to taxes_path
		else
			flash.now[:errors] = "Gawd. Fill everything in man."
			@tax = tax
			render "edit"
		end
	end

	def destroy
		tax = Tax.find(params[:id]).destroy
		flash[:success] = "#{tax.name} has been deleted."
		redirect_to taxes_path
	end
end