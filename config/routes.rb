Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get 'spotify/new', to: 'spotify#new', as: :new_spotify
  get '/auth/spotify/callback', to: 'spotify#authenticate'
  get 'spotify_canvas', to: 'spotify_canvas#index'
  get 'spotify_canvas/current_track', to: 'spotify_canvas#current_track'
end
