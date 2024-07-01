class DeveloperSettings < RailsSettings::Base
  self.table_name = 'developer_settings'
  cache_prefix { "v1" }

  field :developer_mode_enabled, type: :boolean, default: false
  field :display_fps_meter, type: :boolean, default: false
end
