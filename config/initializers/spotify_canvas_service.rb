canvas_service_config = {
  canvas_authentication_url: Rails.configuration.upframe_api.spotify_canvas_access_token_url,
  canvas_url: Rails.configuration.upframe_api.spotify_canvas_url
}

SpotifyCanvasService.instance.configure(canvas_service_config)