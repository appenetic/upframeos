require 'net/http'
require_relative '../services/qrcode_service'
require_relative '../services/system_info_service'

class StartupController < ApplicationController
  def index
    system_info_service = SystemInfoService.new

    # Fetch system information which includes the IP address
    system_info = system_info_service.fetch_system_info

    # Use the fetched IP address in the URL
    url = "http://#{system_info[:v4_ip_address]}/admin/settings/"

    qr_code_service = QRCodeService.new
    @qr_svg = qr_code_service.generate(url)

    is_connected = internet_connection?

    @notice_title = is_connected ? 'Connected!' : 'Not connected'
    # Inside your Ruby controller or wherever the @notice_message is set
    @notice_message = if is_connected
                        "Internet connection successful.<br>IP-Address: #{system_info[:v4_ip_address]}".html_safe
                      else
                        'Please connect your upframe to a wifi network'
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