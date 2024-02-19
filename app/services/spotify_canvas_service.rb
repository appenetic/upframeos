require_relative '../../api/SpotifyCanvasAPI_pb.rb'
require 'google/protobuf'
require 'net/http'
require 'uri'
require 'logger'

# The SpotifyCanvasService class is responsible for interacting with the Spotify Canvas API.
# It provides functionality to authenticate with the Spotify API and fetch canvas URLs for tracks.
#
# Example:
#   config = {
#     canvas_url: 'https://api.spotify.com/v1/canvases',
#     canvas_authentication_url: 'https://accounts.spotify.com/api/token'
#   }
#   spotify_canvas_service = SpotifyCanvasService.new(config)
#   canvas_url = spotify_canvas_service.fetch_canvas_url('spotify:track:123')
class SpotifyCanvasService
  # Constants used for HTTP request headers and response handling.
  CONTENT_TYPE = "Content-Type".freeze
  AUTHORIZATION = "Authorization".freeze
  APPLICATION_X_PROTOBUF = "application/x-protobuf".freeze
  BEARER = "Bearer".freeze
  HTTP_SUCCESS = '200'.freeze

  # Initializes a new instance of the SpotifyCanvasService class.
  #
  # @param config [Hash] Configuration hash containing the canvas URL and authentication URL.
  def initialize(config)
    @config = config
    @logger = Logger.new($stdout)
  end

  # Fetches the canvas URL for a given track URI using the Spotify Canvas API.
  #
  # @param track_uri [String] The Spotify track URI.
  # @return [String, nil] The canvas URL if found and accessible, 'Authentication failed' if authentication fails,
  #   'Failed to fetch canvas URL' if the request is unsuccessful, or nil if an error occurs.
  def fetch_canvas_url(track_uri)
    access_token = authenticate
    return nil unless access_token

    canvas_request = CanvasRequest.new(tracks: [CanvasRequest::Track.new(track_uri: track_uri)])
    serialized_request = CanvasRequest.encode(canvas_request)

    response = execute_http_request(@config[:canvas_url], method: :post, headers: {
      CONTENT_TYPE => APPLICATION_X_PROTOBUF,
      AUTHORIZATION => "#{BEARER} #{access_token}"
    }, body: serialized_request)

    return 'Failed to fetch canvas URL' unless response.code == HTTP_SUCCESS

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
    response = execute_http_request(@config[:canvas_authentication_url])
    return nil unless response.code == HTTP_SUCCESS

    JSON.parse(response.body)["accessToken"]
  rescue JSON::ParserError => e
    @logger.error("JSON parsing error: #{e.message}")
    nil
  rescue => e
    @logger.error("Authentication failed: #{e.message}")
    nil
  end

  # Executes an HTTP request to a given URL with specified parameters.
  #
  # @param url [String] The URL to which the request is made.
  # @param method [Symbol] The HTTP method (:get or :post).
  # @param headers [Hash] The request headers.
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
  # @param method [Symbol] The HTTP method (:get or :post).
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
