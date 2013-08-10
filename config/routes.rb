require 'resque/server'

Totablets::Application.routes.draw do

	root to: 'pages#home'

  resources :rentals, :only => [:create]
  post "/location_info" => "rentals#location_info", :as => :location_info
  post "/capture_customer_data" => "rentals#capture_customer_data", :as => :capture_customer_data
  post "/admin_command" => "rentals#admin_command", :as => :admin_command

  scope '/admin' do
	  get '/' => 'admins#index', :as => :admin_index
	  resources :rentals, :only => [:index, :show]
	  resources :customers, :only => [:index, :show]
	  resources :locations, :except => [:show]
	  resources :devices, :except => [:show]
	  resources :taxes, :except => [:show]
	  resources :pre_auths, :only => [:index, :show, :edit, :update]
	end

  mount Resque::Server.new, :at => "/resque"

end
