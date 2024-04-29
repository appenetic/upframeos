require 'net/http'
require_relative '../services/qrcode_service'

class StartupController < ApplicationController
  def index
    # Check for internet connectivity
    if setup_complete?
      # Redirect to the root route if there's internet connectivity
      redirect_to root_url
    else
      url = 'http://192.168.1.1/admin/settings/'

      qr_code_service = QRCodeService.new
      @qr_svg = qr_code_service.generate(url)
    end
  end

  private

  def internet_connection?
    begin
      true if Net::HTTP.get(URI('http://www.google.com'))
    rescue
      false
    end
  end

  def setup_complete?
    spotify_configured = SpotifyUser.first
    artwork_configured = Artwork.first

    internet_connection? && (spotify_configured || artwork_configured)
  end
end
