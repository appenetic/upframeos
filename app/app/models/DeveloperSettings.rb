class DeveloperSettings < RailsSettings::Base
  cache_prefix { "v1" }

  field :developer_mode_enabled
  field :display_fps_meter
end
