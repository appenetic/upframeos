require 'net/http'
require_relative '../services/qrcode_service.rb'

class StartupController < ApplicationController
  def index
    # Check for internet connectivity
    if internet_connection?
      # Redirect to the root route if there's internet connectivity
      redirect_to root_url
    else
      # Proceed with the original logic if there's no internet connectivity
      local_ip = '192.168.1.1'
      url = "http://#{local_ip}:3000/admin/settings/"

      qr_code_service = QRCodeService.new
      @qr_svg = qr_code_service.generate(url)
    end
  end

  private

  def internet_connection?
    begin
      # Try to connect to a reliable website
      true if Net::HTTP.get(URI('http://www.google.com'))
    rescue
      # Return false if the connection attempt fails
      false
    end
  end
end
