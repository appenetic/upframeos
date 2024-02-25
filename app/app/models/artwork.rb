class Artwork < ApplicationRecord
    has_one_attached :video
    has_one_attached :image

    def title
        if video.present?
            return video.filename
        end

        if image.present?
            return image.filename
        end
    end

    def url
        if video.present?
            return video.url
        end

        if image.present?
            return image.url
        end
    end
end
