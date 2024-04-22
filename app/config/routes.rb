Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root to: 'canvas#index'

  resources :settings
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get 'spotify/new', to: 'spotify#new', as: :new_spotify
  get '/auth/spotify/callback', to: 'spotify#authenticate'
  get '/', to: 'canvas#index'
  get '/startup', to: 'startup#index'
  get '/artwork_data', to: 'canvas#artwork_data'
  get '/current_track', to: 'canvas#current_track'
  get '/playing_status', to: 'canvas#playing_status'
  get '/content', to: 'canvas#content'
end