Totablets::Application.routes.draw do
  resources :rentals, :only => [:create]
end
