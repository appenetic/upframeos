require 'net/http'
require 'uri'
require 'json'
require 'base64'

SPOTIFY_CLIENT_ID = ENV['d68b6a0121534eaaaf2b30e1063fb451']
SPOTIFY_CLIENT_SECRET = ENV['375dd4240cdd4b92ae61c2c5a2867bee']
SPOTIFY_REFRESH_TOKEN = ENV['AQDfmb1W1h0B-hMPTps_7W_LUuua5Egida-I0ve90QiodDB4Yp53YgQwmtzc23QHsQipZAZJAYy0ckqNkEUiPzq3Ya-dAoDywVFjc4kJ90LNknfSVnZ0qJ8p4N158e7TR4A']

def get_canvas_token
  uri = URI('https://open.spotify.com/get_access_token?reason=transport&productType=web_player')
  response = Net::HTTP.get_response(uri)
  if response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)['accessToken']
  else
    puts "ERROR #{uri}: #{response.code} #{response.message}"
    nil
  end
rescue => e
  puts "ERROR #{uri}: #{e}"
  nil
end

def get_personal_token
  uri = URI('https://accounts.spotify.com/api/token')
  request = Net::HTTP::Post.new(uri)
  request.content_type = 'application/x-www-form-urlencoded'
  request['Authorization'] = 'Basic ' + Base64.strict_encode64("#{SPOTIFY_CLIENT_ID}:#{SPOTIFY_CLIENT_SECRET}")
  request.body = URI.encode_www_form({
    grant_type: 'refresh_token',
    refresh_token: SPOTIFY_REFRESH_TOKEN,
  })

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end

  if response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)['access_token']
  else
    puts "ERROR #{uri}: #{response.code} #{response.message}"
    nil
  end
rescue => e
  puts "ERROR #{uri}: #{e}"
  nil
end

def get_recently_played(token)
  uri = URI('https://api.spotify.com/v1/me/player/recently-played?limit=50')
  request = Net::HTTP::Get.new(uri)
  request['Authorization'] = "Bearer #{token}"

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end

  if response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  else
    puts "ERROR #{uri}: #{response.code} #{response.message}"
    nil
  end
rescue => e
  puts "ERROR #{uri}: #{e}"
  nil
end

# Example usage
canvas_token = get_canvas_token

  rp_tracks = get_recently_played("BQAqUOGUmF5H2VIM_o3lnoNNYMCtS2ZvhSfNvunaIVPyXxDARNJCRptjzACWiL0ucbXzK2CLvwYL9LW7aiI19kcSRdF-0UB1kSLTdnuw_8DmwFHFA7HotfyyY57w24KXWCyXQBBgsX3Wh22FV4wwKRrfmxvWhAOmLv-xPfiFoHGL-4VyXb-B8JNPifHAl2FQLhgpcaCXkdbQ1KYMdY8xHg-WTfClBUgn-OoquKjMdPaqBP8")
  # Further processing of rp_tracks to fetch canvases and manipulate data as needed
  puts rp_tracks
