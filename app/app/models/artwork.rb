# frozen_string_literal: true

class Artwork < ApplicationRecord
  has_one_attached :asset
  enum fill_mode: { fill_screen: 0, fit_screen: 1 }

  def url
    Rails.application.routes.url_helpers.rails_blob_url(asset, only_path: true)
  end

  # @return [FalseClass, TrueClass]
  def is_video?
    return false unless asset.attached?

    content_type = asset.blob.content_type
    content_type.start_with?('video/')
  end

  # @return [FalseClass, TrueClass]
  def is_image?
    return false unless asset.attached?

    content_type = asset.blob.content_type
    content_type.start_with?('image/')
  end
end
