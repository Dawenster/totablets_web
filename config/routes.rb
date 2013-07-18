require 'resque/server'

Totablets::Application.routes.draw do
  resources :rentals, :only => [:create]

  mount Resque::Server.new, :at => "/resque"
end
