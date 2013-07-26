require 'resque/server'

Totablets::Application.routes.draw do
  constraints(:host => "totablets.com") do
	  match "(*x)" => redirect { |params, request|
	    URI.parse(request.url).tap { |x| x.host = "www.totablets.com" }.to_s
	  }
	end 

	root to: 'pages#home'

  resources :rentals, :only => [:create]
  post "/capture_customer_data" => "rentals#capture_customer_data", :as => :capture_customer_data

  mount Resque::Server.new, :at => "/resque"

end
