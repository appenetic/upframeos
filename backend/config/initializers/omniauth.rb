require 'rspotify/oauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, Rails.configuration.upframe_api.spotify_client_id, Rails.configuration.upframe_api.spotify_client_secret, scope: Rails.configuration.upframe_api.spotify_permission_scope
end

OmniAuth.config.allowed_request_methods = [:post, :get]