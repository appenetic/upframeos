# RailsSettings Model
class Settings < RailsSettings::Base
  cache_prefix { "v1" }

  scope :general do
    field :orientation, default: "portrait", validates: { presence: true, inclusion: { in: %w[portrait landscape] } }, option_values: %w[portrait landscape]
  end

  scope :spotify do
    field :canvas_feature_enabled, type: :boolean, default: true
  end
end
