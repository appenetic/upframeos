require 'net/http'
require_relative '../services/qrcode_service'

class SpotifyYamController < ApplicationController
  def index
    qr_code_service = QRCodeService.new
    yam_url = Settings.find_by(var: :yam_url).value
    @qr_svg = qr_code_service.generate(yam_url, 6.5)
  end
end