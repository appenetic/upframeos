# RailsSettings Model
class Settings < RailsSettings::Base
  cache_prefix { "v1" }

  scope :general do
    field :orientation, default: "portrait", validates: { presence: true, inclusion: { in: Settings.orientations } }, option_values: Settings.orientations
    field :wifi_country, default: "de", validates: { presence: true, inclusion: { in: Settings.wifi_country_codes } }, option_values: Settings.wifi_country_codes
    field :wifi_ssid
    field :wifi_password
  end

  scope :spotify do
    field :canvas_feature_enabled, type: :boolean, default: true
  end

  def self.orientations
    %w[portrait portrait_inverted landscape landscape_inverted]
  end

  def self.wifi_country_codes
    %w[gb fr de us se]
  end
  
  def self.unix_orientation(orientation)
    case orientation
    when 'portrait'
      'left'
    when 'portrait_inverted'
      'right'
    when 'landscape'
      'normal'
    when 'landscape_inverted'
      'flipped'
    else
      'left'
    end
  end

  def self.wpa_supplicant_content
    country = Settings.wifi_country
    ssid = Settings.wifi_ssid
    psk = Settings.wifi_password
  
    <<-WPA_CONFIG
  country=#{country}
  update_config=1
  ctrl_interface=/var/run/wpa_supplicant
  
  network={
   scan_ssid=1
   ssid="#{ssid}"
   psk="#{psk}"
  }
    WPA_CONFIG
  end
end
