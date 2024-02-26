require 'rqrcode'
class QRCodeService
  def generate(url)
    qrcode = RQRCode::QRCode.new(url)
    svg = qrcode.as_svg(
      offset: 0,
      color: 'ffffff',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true,
      background: '000'
    )
    svg.html_safe
  end
end