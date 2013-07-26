require 'resque/server'

Totablets::Application.routes.draw do
	root to: 'pages#home'

  resources :rentals, :only => [:create]
  post "/capture_customer_data" => "rentals#capture_customer_data", :as => :capture_customer_data

  mount Resque::Server.new, :at => "/resque"

  constraints(:host => /totablets.com/) do
    root :to => redirect("https://www.totablets.com")
      match '/*path', :to => redirect {|params| "https://www.totablets.com/#{params[:path]}"}
    end
	end
end
