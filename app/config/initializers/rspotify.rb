begin
  RSpotify::authenticate(
    Rails.configuration.upframe_api.spotify_client_id,
    Rails.configuration.upframe_api.spotify_client_secret
  )
rescue => e
  Rails.logger.error "Failed to authenticate with Spotify: #{e.message}"
end