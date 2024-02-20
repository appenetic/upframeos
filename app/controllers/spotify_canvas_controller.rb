require_relative '../services/spotify_canvas_service.rb'

class SpotifyCanvasController < ApplicationController
  before_action :set_user
  before_action :initialize_player
  before_action :check_playback

  def index
    @artist_name = @player.currently_playing.artists.first.name
    @album_name = @player.currently_playing.album.name
    @track_name = @player.currently_playing.name
    @reload_after_ms = (@player.currently_playing.duration_ms - @player.progress) + 2000
    @canvas_url = SpotifyCanvasService.instance.fetch_canvas_url(@player.currently_playing.uri)
    @cover_image_url = @player.currently_playing.album.images.first["url"]
    @background_color = extract_main_color(@cover_image_url)
  end

  def current_track
    @player = initialize_player
    if @player.present? && @player.currently_playing
      render json: {
        artist_name: @player.currently_playing.artists.first.name,
        album_name: @player.currently_playing.album.name,
        track_name: @player.currently_playing.name,
        cover_image_url: @player.currently_playing.album.images.first["url"],
        canvas_url: SpotifyCanvasService.instance.fetch_canvas_url(@player.currently_playing.uri),
        background_color: extract_main_color(@player.currently_playing.album.images.first["url"]),
        reload_after_ms: (@player.currently_playing.duration_ms - @player.progress) + 2000
      }
    else
      render json: { error: "No track currently playing" }, status: :not_found
    end
  end

  private

  def extract_main_color(image_url)
    image = MiniMagick::Image.open(image_url)
    result = image.run_command("convert", image.path, "-resize", "1x1", "txt:-")
    color = result.match(/#[\h]{6}/)[0]
    color
  rescue => e
    Rails.logger.error "Failed to extract main color: #{e.message}"
    nil
  end

  def set_user
    @user = SpotifyUser.first
    handle_no_user if @user.blank?
  end

  def initialize_player
    if @user 
      user = RSpotify::User.new(@user.auth_data)

      if user.present?
        @player = user.player
      end
    end
  end

  def check_playback
    handle_no_playback if @player.nil? || @player.is_playing.nil?
  end

  def handle_no_user
    redirect_to controller: :spotify, action: :new
  end

  def handle_no_playback
    flash[:alert] = 'No playback.'
    redirect_to controller: :artworks, action: :index
  end
end
