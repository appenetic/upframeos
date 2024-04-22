
class Artwork < ApplicationRecord
    has_one_attached :video
    has_one_attached :image

    def title
        if video.present?
            video.filename
        end

        if image.present?
            image.filename
        end
    end

    def url
        if video.attached?
            Rails.application.routes.url_helpers.rails_blob_url(video, only_path: true)
        elsif image.attached?
            Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
        end
    end
end
