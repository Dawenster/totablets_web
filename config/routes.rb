require 'resque/server'

Totablets::Application.routes.draw do

	root to: 'pages#home'

  resources :rentals, :only => [:create]
  post "/capture_customer_data" => "rentals#capture_customer_data", :as => :capture_customer_data

  resources :locations
  resources :devices
  resources :taxes

  mount Resque::Server.new, :at => "/resque"

end
