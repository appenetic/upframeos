require 'rqrcode'
class QRCodeService
  def generate(url, size)
    qrcode = RQRCode::QRCode.new(url)
    svg = qrcode.as_svg(
      offset: 0,
      color: '000000',
      shape_rendering: 'crispEdges',
      module_size: size,
      standalone: true,
      background: '000'
    )
    svg.html_safe
  end
end