# RailsSettings Model
class Settings < RailsSettings::Base
  cache_prefix { "v1" }

  scope :general do
    field :orientation, default: "portrait", validates: { presence: true, inclusion: { in: orientations } }, option_values: orientations
  end

  scope :spotify do
    field :canvas_feature_enabled, type: :boolean, default: true
  end

  def orientations
    %w[portrait portrait_inverted landscape landscape_inverted]
  end
  
  def unix_orientation(orientation)
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
end
