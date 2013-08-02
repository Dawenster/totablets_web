require 'resque/server'

Totablets::Application.routes.draw do

	root to: 'pages#home'

  resources :rentals, :only => [:create]
  post "/capture_customer_data" => "rentals#capture_customer_data", :as => :capture_customer_data

  scope '/admin' do
	  get '/' => 'admins#index', :as => :admin_index
	  resources :locations, :except => [:show]
	  resources :devices, :except => [:show]
	  resources :taxes, :except => [:show]
	end

  mount Resque::Server.new, :at => "/resque"

end
