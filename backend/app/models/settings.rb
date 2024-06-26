class Settings < RailsSettings::Base
  cache_prefix { "v1" }

  field :orientation,validates: { presence: true, inclusion: { in: Constants.orientations } }, option_values: Constants.orientations
  field :wifi_country, validates: { presence: true, inclusion: { in: Constants.wifi_country_codes } }, option_values: Constants.wifi_country_codes
  field :wifi_ssid
  field :wifi_password
  field :canvas_feature_enabled, type: :boolean
  field :yam_feature_enabled, type: :boolean
  field :yam_url

  def self.unix_orientation
    case orientation
    when 'portrait'
      'rotate-90'  # rotated 90 degrees clockwise
    when 'portrait_inverted'
      'rotate-270' # rotated 270 degrees clockwise
    when 'landscape'
      'normal' # no rotation
    when 'landscape_inverted'
      'rotate-180' # rotated 180 degrees
    else
      'normal' # default to no rotation
    end
  end

  def self.wpa_supplicant_content
    country = Settings.find_by(var: :wifi_country).value
    ssid = Settings.find_by(var: :wifi_ssid).value
    psk = Settings.find_by(var: :wifi_password).value
  
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
