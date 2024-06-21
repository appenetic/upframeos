# Settings with default values
default_settings = {
  orientation: "portrait",
  wifi_country: "de",
  wifi_ssid: "",
  wifi_password: "",
  canvas_feature_enabled: true,
  yam_feature_enabled: true,
  yam_url: ""
}

default_settings.each do |key, value|
  Settings.find_or_create_by(var: key.to_s) { |s| s.value = value }
end

# Developer settings
developer_settings = {
  developer_mode_enabled: false,
  display_fps_meter: false
}

developer_settings.each do |key, value|
  DeveloperSettings.find_or_create_by(var: key.to_s) { |s| s.value = value }
end
