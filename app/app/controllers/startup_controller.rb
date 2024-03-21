require 'net/http'
require_relative '../services/qrcode_service'

class StartupController < ApplicationController
  def index
    # Check for internet connectivity
    if internet_connection?
      # Redirect to the root route if there's internet connectivity
      redirect_to root_url
    else
      url = 'http://upframe.local/admin/settings/'

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
end
