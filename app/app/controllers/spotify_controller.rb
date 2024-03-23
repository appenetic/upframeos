class SpotifyController < ApplicationController
  def authenticate
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    spotify_user_hash = spotify_user.to_hash

    SpotifyUser.new(
      mail: spotify_user.email,
      auth_data: spotify_user_hash
    ).save

    redirect_to '/admin/settings', notice: 'Successfully authenticated with Spotify.'
  end
end