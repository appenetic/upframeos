# frozen_string_literal: true

require_relative '../services/spotify_canvas_service'

class CanvasController < ApplicationController
  before_action :set_user
  before_action :initialize_player
  before_action :playback_active?
  before_action :playback_active?, except: [:playing_status]

  def current_track
    @player = initialize_player
    if @player.present? && @player.respond_to?(:currently_playing) && @player.currently_playing
      render json: {
        artist_name: @player.currently_playing.artists.first.name,
        album_name: @player.currently_playing.album.name,
        track_name: @player.currently_playing.name,
        cover_image_url: @player.currently_playing.album.images.first['url'],
        canvas_url: SpotifyCanvasService.instance.fetch_canvas_url(@player.currently_playing.uri),
        background_color: extract_main_color(@player.currently_playing.album.images.first['url']),
        reload_after_ms: (@player.currently_playing.duration_ms - @player.progress) + 2000
      }
    else
      render json: { error: 'No track currently playing' }, status: :not_found
    end
  end

  def content
    html_content = if playback_active?
                     render_to_string(partial: 'spotify',
                                      locals: { spotify_data: spotify_data })
                   else
                     render_to_string(partial: 'artwork',
                                      locals: { artwork_data: artwork_data }
                     )
                   end

    render html: html_content.html_safe
  end

  def playing_status
    if @player&.is_playing
      render json: { playing: true }
    else
      render json: { playing: false }
    end
  end

  private

  def spotify_data
    currently_playing = @player.currently_playing
    data = {
      artist_name: currently_playing.artists.first.name,
      album_name: currently_playing.album.name,
      track_name: currently_playing.name,
      reload_after_ms: (currently_playing.duration_ms - @player.progress) + 2000,
      cover_image_url: currently_playing.album.images.first['url'],
      background_color: extract_main_color(currently_playing.album.images.first['url'])
    }

    # Only fetch the canvas URL if Settings.canvas_feature is true
    if Settings.canvas_feature_enabled
      data[:canvas_url] = SpotifyCanvasService.instance.fetch_canvas_url(currently_playing.uri)
    end

    data
  end

  def artwork_data
    artwork = Artwork.order('RANDOM()').first

    data = {}

    # Ensure artwork object is present
    if artwork.present?
      data[:artwork_image_url] = url_for(artwork.image) if artwork.image.present?
      data[:artwork_video_url] = url_for(artwork.video) if artwork.video.present?

      duration = artwork.duration || 60 * 1000
      data[:reload_after_ms] = duration * 1000
    else
      Rails.logger.warn 'No artwork found. Using default data.'
    end

    data
  end

  def playback_active?
    @playback_active = @player.present? && @player.is_playing.present?
  end

  def extract_main_color(image_url)
    image = MiniMagick::Image.open(image_url)
    result = image.run_command('convert', image.path, '-resize', '1x1', 'txt:-')
    result.match(/#\h{6}/)[0]
  rescue StandardError => e
    Rails.logger.error "Failed to extract main color: #{e.message}"
    nil
  end

  def set_user
    @user = SpotifyUser.first
    handle_no_user if @user.blank?
  end

  def initialize_player
    return unless @user

    begin
      user = RSpotify::User.new(@user.auth_data)
      @player = user.player if user.present?
    rescue StandardError => e
      Rails.logger.error "Failed to initialize Spotify player: #{e.message}"
    end
  end

  def handle_no_user
    redirect_to controller: :spotify, action: :new
  end
end
