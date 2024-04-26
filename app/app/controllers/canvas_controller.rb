# frozen_string_literal: true

require_relative '../services/spotify_canvas_service'

class CanvasController < ApplicationController
  before_action :set_user
  before_action :initialize_player
  before_action :playback_active?, except: [:playing_status]

  def current_track
    retries = 0
    track_uri = @player&.currently_playing&.uri

    # Check cache first
    cached_data = Rails.cache.read(track_uri)
    if track_uri && cached_data && Time.now - cached_data[:timestamp] < 1800
      head :not_modified
      return
    end

    begin
      if @player.present? && @player.respond_to?(:currently_playing) && @player.currently_playing
        response_body = {
          track_uri: track_uri,
          artist_name: @player.currently_playing.artists.first.name,
          album_name: @player.currently_playing.album.name,
          track_name: @player.currently_playing.name,
          cover_image_url: @player.currently_playing.album.images.first['url'],
          canvas_url: SpotifyCanvasService.instance.fetch_canvas_url(track_uri),
          background_color: extract_main_color(@player.currently_playing.album.images.first['url']),
          reload_after_ms: (@player.currently_playing.duration_ms - @player.progress) + 2000
        }

        Rails.cache.write(track_uri, { response: response_body, timestamp: Time.now })

        render json: response_body
      else
        render json: { error: 'No track currently playing' }, status: :not_found
      end
    rescue => e
      retries += 1
      if retries < 3
        sleep 2 ** retries
        retry
      else
        # Log the error and respond with an error message
        logger.error "Failed to connect after 3 retries: #{e.message}"
        render json: { error: 'Failed to connect to the external service' }, status: :service_unavailable
      end
    end
  end

  def content
    html_content = if playback_active?
                     render_to_string(partial: 'spotify',
                                      locals: { spotify_data: spotify_data })
                   else
                     render_to_string(partial: 'artwork')
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

  def artwork_data
    artwork = Artwork.order('RANDOM()').first

    data = {}

    # Ensure artwork object is present
    if artwork.present?
      data[:asset_url] = artwork.url
      data[:is_video] = artwork.is_video?
      data[:fill_mode] = artwork.fill_mode

      render json: data
    else
      Rails.logger.warn 'No artwork found. Using default data.'
    end

    data
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
    if Settings.find_by(var: :canvas_feature_enabled).value == true
      data[:canvas_url] = SpotifyCanvasService.instance.fetch_canvas_url(currently_playing.uri)
    end

    data
  end

  def playback_active?
    @playback_active = @player.present? && @player.is_playing.present?
  end

  def extract_main_color(image_url)
    # Attempt to fetch the cached color for the given image_url
    cached_color = Rails.cache.fetch(image_url, expires_in: 20.minutes)
    return cached_color if cached_color.present?

    # If the color is not cached, proceed to extract it from the image
    image = MiniMagick::Image.open(image_url)
    result = image.run_command('convert', image.path, '-resize', '1x1', 'txt:-')
    color = result.match(/#\h{6}/)[0]

    # Cache the extracted color before returning it
    Rails.cache.write(image_url, color, expires_in: 20.minutes)
    color
  rescue StandardError => e
    Rails.logger.error "Failed to extract main color: #{e.message}"
    nil
  end

  def set_user
    @user = Rails.cache.fetch('spotify_user', expires_in: 1.hour) do
      SpotifyUser.first
    end
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
    redirect_to controller: :startup, action: :index
  end
end
