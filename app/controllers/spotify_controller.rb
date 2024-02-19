class SpotifyController < ApplicationController

  def new
    
  end

  def authenticate
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    spotify_user_hash = spotify_user.to_hash

    pp player = spotify_user.player

    SpotifyUser.new(
      mail: spotify_user.email,
      auth_data: spotify_user_hash
    ).save

    redirect_to :spotify_canvas
  end
end