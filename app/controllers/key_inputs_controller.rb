class KeyInputsController < ApplicationController
	http_basic_authenticate_with :name => ENV['ADMIN_NAME'], :password => ENV['ADMIN_PASSWORD']

	def show
		@key_input = KeyInput.last
	end

	def edit
		@key_input = KeyInput.last
	end

	def update
		key_input = KeyInput.last

		key_input.rate = (params[:key_input][:rate].to_f * 100).to_i
		key_input.pre_auth_amount = (params[:key_input][:pre_auth_amount].to_f * 100).to_i
		key_input.terms_and_conditions = params[:key_input][:terms_and_conditions]
		key_input.apple_id_password = params[:key_input][:apple_id_password]
		key_input.warning = params[:key_input][:warning]

		if key_input.save
			flash[:success] = "Key information have been updated."
			redirect_to key_input_path(key_input)
		else
			flash.now[:errors] = "Gawd. Fill everything in man."
			@key_input = key_input
			render "edit"
		end
	end
end