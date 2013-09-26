require 'resque/server'

Totablets::Application.routes.draw do

	root to: 'pages#home'

  scope '/admin' do
	  get '/' => 'admins#index', :as => :admin_index
	  resources :key_inputs, :only => [:show, :edit, :update]
	  resources :rentals, :only => [:index, :show]
	  resources :customers, :only => [:index, :show]
	  resources :locations, :except => [:show]
	  resources :notifications, :except => [:show]
	  resources :devices, :except => [:show]
	  resources :taxes, :except => [:show]
	  resources :pre_auths, :only => [:index, :show, :edit, :update]
	  resources :admin_accesses, :only => [:index]
	end

  resources :rentals, :only => [:create]
  post "/location_info" => "rentals#location_info", :as => :location_info
  post "/capture_customer_data" => "rentals#capture_customer_data", :as => :capture_customer_data
  post "/admin_command" => "rentals#admin_command", :as => :admin_command
  post "/install_apps" => "rentals#install_apps", :as => :install_apps

  mount Resque::Server.new, :at => "/resque"

end
