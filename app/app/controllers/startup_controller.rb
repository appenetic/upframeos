require_relative '../services/qrcode_service.rb'
class StartupController < ApplicationController
  def index
    local_ip = '192.168.1.1'
    url = "http://#{local_ip}:3000/admin/"

    qr_code_service = QRCodeService.new
    @qr_svg = qr_code_service.generate(url)
  end
end