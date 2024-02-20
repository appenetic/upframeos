require_relative '../../api/SpotifyCanvasAPI_pb.rb'
require 'google/protobuf'
require 'net/http'
require 'uri'
require 'logger'

# The SpotifyCanvasService class is responsible for interacting with the Spotify Canvas API.
# It provides functionality to authenticate with the Spotify API and fetch canvas URLs for tracks.
#
# The class uses the Singleton pattern to ensure only one instance is created,
# making it easier to manage configurations and tokens across the application.
#
# Example Usage:
# --------------
# canvas_service_config = {
#   canvas_authentication_url: 'https://accounts.spotify.com/api/token',
#   canvas_url: 'https://api.spotify.com/v1/canvases',
#   logger: Rails.logger
# }
#
# SpotifyCanvasService.instance.configure(canvas_service_config)
# canvas_url = SpotifyCanvasService.instance.fetch_canvas_url('spotify:track:123')
class SpotifyCanvasService include Singleton
  CONTENT_TYPE = "Content-Type".freeze
  AUTHORIZATION = "Authorization".freeze
  APPLICATION_X_PROTOBUF = "application/x-protobuf".freeze
  BEARER = "Bearer".freeze
  HTTP_SUCCESS = '200'.freeze
  HTTP_UNAUTHORIZED = '401'.freeze

  attr_accessor :logger

  # Configures the singleton instance with necessary parameters.
  #
  # @param config [Hash] A configuration hash that includes:
  #   - :canvas_authentication_url [String] The URL for authentication.
  #   - :canvas_url [String] The base URL for the Spotify Canvas API.
  #   - :logger [Logger] (optional) The logger to use, defaults to STDOUT.
  def configure(config)
    @config = config
    @logger = config[:logger] || Logger.new($stdout)
    @access_token = nil # Reset access token to ensure it's re-fetched as needed
  end

  # Fetches the canvas URL for a given Spotify track URI.
  #
  # @param track_uri [String] The Spotify track URI.
  # @return [String, nil] The canvas URL if found and accessible, or nil if an error occurs.
  def fetch_canvas_url(track_uri)
    # Attempt to fetch canvas URL with the current access token if it exists.
    response = @access_token ? attempt_fetch_canvas(track_uri, @access_token) : nil

    if response.nil? || response.code == HTTP_UNAUTHORIZED
      @logger.info("Attempting to authenticate.") if response.nil?
      @logger.info("Authentication expired, attempting to re-authenticate.") if response&.code == HTTP_UNAUTHORIZED

      @access_token = authenticate
      return nil unless @access_token

      response = attempt_fetch_canvas(track_uri, @access_token) # Retry fetching canvas with new token
    end

    if response.code != HTTP_SUCCESS
      @logger.error("Failed to fetch canvas URL: HTTP Status Code #{response.code}")
      return 'Failed to fetch canvas URL'
    end

    CanvasResponse.decode(response.body).canvases.first&.canvas_url
  rescue => e
    @logger.error("Failed to fetch canvas URL: #{e.message}")
    nil
  end

  private

  # Authenticates with the Spotify API to obtain an access token.
  #
  # @return [String, nil] The access token if authentication is successful, or nil if it fails.
  def authenticate
    response = execute_http_request(@config[:canvas_authentication_url], method: :get)
    return nil unless response.code == HTTP_SUCCESS

    json = JSON.parse(response.body)
    access_token = json['accessToken']

    return access_token
  rescue JSON::ParserError => e
    @logger.error("JSON parsing error: #{e.message}")
    nil
  rescue => e
    @logger.error("Authentication failed: #{e.message}")
    nil
  end

  # Attempts to fetch the canvas information for a given track URI using the access token.
  #
  # @param track_uri [String] The Spotify track URI.
  # @param access_token [String] The access token for Spotify API.
  # @return [Net::HTTPResponse] The HTTP response from the Canvas API request.
  def attempt_fetch_canvas(track_uri, access_token)
    canvas_request = CanvasRequest.new(tracks: [CanvasRequest::Track.new(track_uri: track_uri)])
    serialized_request = CanvasRequest.encode(canvas_request)

    execute_http_request(@config[:canvas_url], method: :post, headers: {
      CONTENT_TYPE => APPLICATION_X_PROTOBUF,
      AUTHORIZATION => "#{BEARER} #{access_token}"
    }, body: serialized_request)
  end

  # Executes an HTTP request to a given URL with specified parameters.
  #
  # @param url [String] The URL to which the request is made.
  # @param method [Symbol] (:get or :post) The HTTP method to use for the request.
  # @param headers [Hash] The HTTP headers for the request.
  # @param body [String, nil] The request body, for POST requests.
  # @return [Net::HTTPResponse] The response from the HTTP request.
  def execute_http_request(url, method: :get, headers: {}, body: nil)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = create_request(uri, method, headers, body)
    http.request(request)
  end

  # Creates an HTTP request object based on method, URL, headers, and body.
  #
  # @param uri [URI] The URI object created from the request URL.
  # @param method [Symbol] (:get or :post) The HTTP method.
  # @param headers [Hash] The HTTP headers for the request.
  # @param body [String, nil] The body of the request, for POST requests.
  # @return [Net::HTTPRequest] The HTTP request object.
  def create_request(uri, method, headers, body)
    request = case method
              when :post
                Net::HTTP::Post.new(uri, headers)
              else
                Net::HTTP::Get.new(uri, headers)
              end
    request.body = body if body
    request
  end
end
