class PreAuthsController < ApplicationController
	http_basic_authenticate_with :name => ENV['ADMIN_NAME'], :password => ENV['ADMIN_PASSWORD']
	
	def index
		@pre_auths = PreAuth.order("created_at DESC")
	end

	def show
		@pre_auth = PreAuth.find(params[:id])
	end

	def edit
		@pre_auth = PreAuth.find(params[:id])
	end

	def update
		pre_auth = PreAuth.find(params[:id])
		amount = params[:pre_auth][:captured_amount].to_i * 100 # in cents

		if amount <= pre_auth.pre_auth_amount
			Stripe.api_key = ENV['STRIPE_SECRET_KEY']
			ch = Stripe::Charge.retrieve(pre_auth.stripe_pre_auth_id)
			ch.capture(:amount => amount)
			
			pre_auth.update_attributes(
				:captured_amount => pre_auth.captured_amount + amount,
				:description => params[:pre_auth][:description]
			)
			flash[:success] = "Pre-auth ##{pre_auth.id} has been successfully charged."
			redirect_to pre_auth_path(pre_auth)
		else
			flash.now[:errors] = "Don't charge too much... also make sure to fill everything in."
			@pre_auth = pre_auth
			render "edit"
		end
	end
end